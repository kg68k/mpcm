		.include	doscall.mac
		.include	iocscall.mac

*---------------------------------------------------------------
*　　　　　　　　　　定数定義
*---------------------------------------------------------------

TAB		equ		$09
CR		equ		$0d
LF		equ		$0a
EOF		equ		$1a

*▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽
*
*		常駐部分データ
*
*△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△

		.align		4


p8w:
header:		.dc.b		'P8EmUWAC'	* 常駐判定用ヘッダ
trap2_vec_buff:	.ds.l		1		* TRAP #2 ベクタ保存
trap2_nest:	.dc.w		-1		* TRAP #2 多重呼出回数
before_PCM:	.ds.w		16		* 前のPCM登録種類

p8emu_lock:	.ds.b		1		* 占有フラグ
lockmode:	.ds.b		1		* 常駐解除チェックのモード
emumode:	.ds.b		1		* チャンネルエミュレーションのモード



*▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽
*
*		ファンクションコール TRAP #2 処理
*
*△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△
		.even
		.dc.b		'PCM8/048'

p8emu_trap2:
		addi.w		#1,trap2_nest
		bgt		trap2_nested		* trap#2 処理中に再び呼び出された
		movem.l		d1-d7/a0-a6,-(sp)

		lea.l		p8w(pc),a6		* a6.l = ワーク先頭アドレス

		cmpi.w		#$01FE,d0		* 占有
		bne		@f
		pea.l		trap2_ret(pc)
		bra		func_01FE
@@:		cmpi.w		#$01FF,d0		* 占有解除
		bne		@f
		pea.l		trap2_ret(pc)
		bra		func_01FF

@@:		cmpi.w		#$0000+$0010,d0
		bcc		func_error

normal_func:	move.b		d0,d7			* d7.w = チャンネル番号
		andi.w		#$000f,d7

		sub.b		d7,d0			* 下位4bit 殺す
		add.w		d0,d0
		add.w		d0,d0			* d0.w = 機能番号*4
		tst.b		emumode-p8w(a6)
		bne		1f
		lea.l		trap2_jmp_tbl0(pc),a0
		bra		2f
1:		lea.l		trap2_jmp_tbl1(pc),a0

2:		move.l		(a0,d0.w),a0
		pea.l		trap2_ret(pc)
		jmp		(a0)			* 各ファンクションへ

trap2_jmp_tbl0:
		.dc.l		func_m_000x
trap2_jmp_tbl1:
		.dc.l		func_e_000x

reserved:
func_error:	moveq.l		#-1,d0
trap2_ret:	movem.l		(sp)+,d1-d7/a0-a6
trap2_nested:	sub.w		#1,trap2_nest
		rte


*=======================================================
*	機能コード $000x のエミュレーション(演奏チャンネル版)
*=======================================================

panhen:		.dc.b		64,0,127,64

func_m_000x:
		tst.l		d2
		bne		@f

		move.w		d7,d0
		addi.w		#$0100,d0
		trap		#1			* キーオフ
		rts

@@:		move.l		d1,d5
		cmpi.b		#$ff,d5			* PANの設定
		beq		@f
		andi.w		#$0003,d1
		move.w		d7,d0
		addi.w		#$0600,d0
		trap		#1			* MPCMのPAN設定

@@:		lsr.w		#8,d5			* 周波数の設定
		cmpi.b		#$ff,d5
		beq		4f
		cmpi.b		#$04+1,d5
		bcc		1f
		move.w		d5,d1			* ADPCMの場合
		moveq.l		#-1,d6
		bra		3f

1:		bne		2f
		moveq.l		#1,d6			* 16bitPCMの場合
		moveq.l		#4,d1
		bra		3f

2:		moveq.l		#2,d6			* 8bitPCMの場合
		moveq.l		#4,d1

3:		move.w		d7,d0
		add.w		d0,d0
		move.w		d6,before_PCM-p8w(a6,d0.w)	* PCMの種類保存
		move.w		d7,d0
		addi.w		#$0300,d0
		trap		#1			* MPCMの周波数設定
		bra		@f

4:		move.w		d7,d0
		add.w		d0,d0
		move.w		before_PCM-p8w(a6,d0.w),d6	* 前のを使う

@@:		swap.w		d5			* 音量の設定
		cmpi.b		#$ff,d5
		beq		@f
		lsl.w		#3,d5
		move.w		d5,d1
*		move.w		#$40,d1
		move.w		d7,d0
		addi.w		#$0500,d0
		trap		#1			* MPCMの音量設定

@@:
		move.w		dummy_key(pc),d1
		add.w		#64*64,d1
		cmp.w		#$1fc0+1,d1
		bcs		1f
		moveq.l		#0,d1
1:		move.w		d1,dummy_key
		move.w		d1,d0
		lsr.w		#6,d0
		move.b		d0,func02xx_work+1	* オリジナルノートのローテーション

		move.w		d7,d0
		addi.w		#$0400,d0
		trap		#1			* 音程設定

		move.w		d7,d0
		addi.w		#$0200,d0
		move.l		a1,func02xx_work+4
		lea.l		func02xx_work(pc),a1
		subq.b		#1,d6			* PCM種類
		bmi		@f
		addq.b		#1,d6
@@:		move.b		d6,(a1)
		move.l		d2,8(a1)		* PCM長さ

		subq.l		#1,d2
		move.l		d2,16(a1)		* PCMループ終点

		trap		#1			* PCMデータの登録

		move.w		d7,d0
		trap		#1			* KEY_ON

		rts

func02xx_work:	.dc.b		0			* PCM種類
		.dc.b		-1			* オリジナルノート
		.dc.w		0			* dummy
		.dc.l		0			* アドレス
		.dc.l		0			* 長さ
		.dc.l		0			* ループ開始
		.dc.l		0			* ループ終了
		.dc.l		1			* ループ回数

dummy_key:	.dc.w		$0000

*=======================================================
*	機能コード $000x のエミュレーション(効果音チャンネル版)
*=======================================================

func_e_000x:
		tst.l		d2
		beq		func_stop_eff_emu
		bpl		@f
		move.l		#-1,d0
		rts

@@:		lea.l		fe_pan(pc),a0
		ori.l		#$ff000000,d1			* default=ADPCM
		move.w		d1,d0

		cmpi.b		#$ff,d0				* pan check
		bne		@f
		move.b		fe_pan-fe_pan(a0,d7.w),d1
@@:		move.b		d1,fe_pan-fe_pan(a0,d7.w)

		lsr.w		#8,d0				* frq check
		cmpi.b		#$ff,d0
		beq		1f
		cmpi.b		#$04+1,d0
		bcs		2f
		andi.l		#$0000000f,d0
		subq.l		#4,d0
		ror.l		#8,d0
		andi.l		#$00ffffff,d1
		or.l		d0,d1				* PCM kind = 8/16bitPCM
		moveq.l		#$04,d0
		bra		2f

1:		move.b		fe_frq-fe_pan(a0,d7.w),d0
2:		move.b		d0,fe_frq-fe_pan(a0,d7.w)
		lsl.w		#8,d0
		andi.w		#$00ff,d1
		or.w		d0,d1


		move.w		d7,d0
		andi.w		#$000f,d0
		ori.w		#$1000,d0

		trap		#1

		moveq.l		#0,d0
		rts

func_stop_eff_emu:
		move.w		d7,d0
		andi.w		#$000f,d0
		ori.w		#$1300,d0
		trap		#1
		moveq.l		#0,d0
		rts


fe_pan:		.ds.b		16
fe_frq:		.ds.b		16
fe_vol:		.ds.b		16

*=======================================================
*	機能コード $01FE のエミュレーション
*=======================================================

func_01FE:	tas.b		p8emu_lock-p8w(a6)
		bne		@f
		moveq.l		#0,d0
		rts
@@:		moveq.l		#-1,d0
		rts

*=======================================================
*	機能コード $01FF のエミュレーション
*=======================================================

func_01FF:	tst.b		p8emu_lock-p8w(a6)
		bne		@f
		moveq.l		#-1,d0
		rts
@@:		clr.b		p8emu_lock-p8w(a6)
		moveq.l		#0,d0
		rts

*▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽
*
*		非常駐部分
*
*△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△

		.text

p8emu_start:	pea.l		title_mes(pc)
		DOS		_PRINT
		addq.l		#4,sp
		movea.l		a0,a6			* a0/a6=メモリ管理ポインタ
		bsr		option_check

		clr.l		-(sp)
		DOS		_SUPER
		move.l		d0,(sp)
		move.l		a6,d0
@@:		movea.l		d0,a6			* 先頭のメモリブロックの直後に移動する
		move.l		(a6),d0
		bne		@b

keep_check:	cmpi.b		#$ff,4(a6)
		bne		@f			* 常駐プロセスではない
		lea.l		$100(a6),a5
		move.l		8(a6),d1
		sub.l		a5,d1
		subq.l		#8,d1
		bcs		@f			* メモリブロックが小さすぎる
		move.l		(a5),d1
		cmp.l		header,d1
		bne		@f			* ヘッダが一致しない
		move.l		4(a5),d1
		cmp.l		header+4,d1
		bne		@f			* ヘッダが一致しない

		DOS		_SUPER
		addq.l		#4,sp
		bra		keeped			* 常駐していた

@@:		move.l		12(a6),d0		* 次のメモリブロックへ
		movea.l		d0,a6
		bne		keep_check

*		<< 常駐していなかった場合 >>

not_keeped:	DOS		_SUPER
		addq.l		#4,sp
		btst.b		#0,option_flag(pc)	* -r check
		bne		error0			* 常駐してないのに常駐解除は出来ない

		clr.b		emumode			* CHエミュレーション=0 (default)
		clr.b		lockmode		* 常駐解除チェックは行う

		btst.b		#1,option_flag(pc)	* -e check
		beq		@f
		st.b		emumode			* CHエミュレーション=$ff (effect)
@@:		btst.b		#2,option_flag(pc)	* -x check
		beq		@f
		move.b		#01,emumode		* CHエミュレーション=$01 (effect nonbusy)

@@:

*		TRAP 2割り込みベクタのフック

		clr.l		-(sp)
		DOS		_SUPER
		move.l		d0,(sp)

		move.l		$0084.w,a0		* MPCMの常駐チェック
		move.l		-8(a0),d0
		cmpi.l		#'MPCM',d0
		beq		@f			* 常駐していた

		DOS		_SUPER
		addq.l		#4,sp
		bra		error2			* MPCMがいないエラー

@@:		lea.l		p8emu_lock_name(pc),a1
		move.w		#$8000,d0
		trap		#1			* MPCM占有
		tst.l		d0
		bpl		@f

		DOS		_SUPER
		addq.l		#4,sp
		bra		error3			* MPCMが占有できないエラー

@@:		move.w		#$8002,d0
		trap		#1			* MPCM初期化
		move.w		#$8005,d0
		move.l		#0,d1
		trap		#1			* MPCM音量テーブルセレクト

		move.l		$0088.w,trap2_vec_buff	* trap2ベクタのフック
		move.l		#p8emu_trap2,$0088.w
		DOS		_SUPER
		addq.l		#4,sp

		pea.l		keep_mes(pc)
		DOS		_PRINT
		addq.l		#4,sp

		clr.w		-(sp)
		lea.l		p8emu_start(pc),a0	* コンパイル時の為
		lea.l		header,a1
		suba.l		a1,a0
		move.l		a0,-(sp)
		DOS		_KEEPPR			* 常駐して終了

*		<< 既に常駐していた場合 >>

keeped:		btst.b		#0,option_flag(pc)	* r オプションが指定されている？
		beq		error1			* '既に常駐'メッセージ

		btst.b		#3,option_flag(pc)	* l オプションが指定されている？
		bne		@f			* 占有を考慮しない!

		tst.b		p8emu_lock-header(a5)
		bne		error5			* p8emuが占有されてまんがな

@@:		lea.l		p8emu_lock_name(pc),a1
		move.w		#$8001,d0
		trap		#1			* MPCM 占有解除
		tst.l		d0
		bmi		error4			* 占有解除できない

		clr.l		-(sp)
		DOS		_SUPER
		move.l		d0,(sp)
		move.w		sr,d0			* sr 保存
		ori.w		#$0700,sr		* 割り込み禁止
		move.l		trap2_vec_buff-header(a5),$0088.w	* trap 2 ベクタ戻す
		DOS		_SUPER
		addq.l		#4,sp

		pea.l		$10(a6)
		DOS		_MFREE
		pea.l		free_mes(pc)
		DOS		_PRINT
		addq.l		#8,sp
		DOS		_EXIT			* 常駐解除終了

*=======================================================
* option_check	: オプション判定&フラグとワークのセット
* call		: (a2)～=コマンドライン
* return	: (opt_flag)とそれぞれのワークに値をセット
* breaks	: d0,d1,a2
*=======================================================
option_check:	addq.l		#1,a2
opt_chk0:	move.b		(a2)+,d0
		tst.b		d0
		beq		opt_ret
		cmpi.b		#'/',d0			* option ?
		beq		opt_chk1
		cmpi.b		#'-',d0			* option ?
		beq		opt_chk1
		cmpi.b		#TAB,d0			* TAB	?
		beq		opt_chk0
		cmpi.b		#' ',d0			* SPACE ?
		beq		opt_chk0
		bra		usage			* 使用法表示

opt_chk1:	move.b		(a2)+,d0
		andi.b		#$df,d0			* 大文字に揃える

		cmpi.b		#'R',d0			* r = 常駐解除
		bne		@f
		or.b		#$01,option_flag	* bit0 = r 用フラグ
		bra		opt_chk0

@@:		cmpi.b		#'E',d0			* e = 効果音CH利用
		bne		@f
		or.b		#$02,option_flag	* bit1 = e 用フラグ
		bra		opt_chk0

@@:		cmpi.b		#'L',d0			* l = 常駐チェック飛ばし
		bne		@f
		or.b		#$08,option_flag	* bit3 = l 用フラグ
		bra		opt_chk0

@@:		bra		usage			* 使用法表示

opt_ret:	rts

*===============================================================
* error		: 非常駐部分エラー処理
* usage		: 使い方表示
*===============================================================
error0:		pea.l		error0_mes(pc)
		bra		error
error1:		pea.l		error1_mes(pc)
		bra		error
error2:		pea.l		error2_mes(pc)
		bra		error
error3:		pea.l		error3_mes(pc)
		bra		error
error4:		pea.l		error4_mes(pc)
		bra		error
error5:		pea.l		error5_mes(pc)
		bra		error
usage:		pea.l		usage_mes(pc)
		bra		error

error:		DOS		_PRINT
		addq.l		#4,sp
		moveq.l		#-1,d0
		DOS		_EXIT2

		.align		4

*===============================================================
* 		非常駐部分固定データ
*===============================================================
		.data

title_mes:	.dc.b		'PCM8 emulator version 0.20A for MPCM '
		.dc.b		'copyright (c) 1994,98 by wachoman',CR,LF,0

keep_mes:	.dc.b		'常駐しました',CR,LF,0
free_mes:	.dc.b		'常駐解除しました',CR,LF,0

error0_mes:	.dc.b		'常駐していません',CR,LF,0
error1_mes:	.dc.b		'既に常駐しています',CR,LF,0
error2_mes:	.dc.b		'MPCMが常駐していません',CR,LF,0
error3_mes:	.dc.b		'MPCMを既に占有しているアプリケーションがあります.常駐できません',CR,LF,0
error4_mes:	.dc.b		'MPCMの占有解除に失敗しました.常駐解除できません',CR,LF,0
error5_mes:	.dc.b		'p8emu.xが占有されています.常駐解除できません',CR,LF,0

usage_mes:	.dc.b		'usage  :  p8emu.x [option]',CR,LF
		.dc.b		'option :  /r ･････････ 常駐解除',CR,LF
		.dc.b		'          /e ･････････ 効果音CHでｴﾐｭﾚｰｼｮﾝ',CR,LF
		.dc.b		'          /l ･････････ p8emuの常駐解除ﾁｪｯｸをしない(-rと組み合わせて指定してください)',CR,LF
		.dc.b		0

p8emu_lock_name:.dc.b		'PCM8 emulator P8emu.x ver 0.20',0

		.align		4

*===============================================================
* 		非常駐部分ワークエリア
*===============================================================
		.bss

option_flag:	.ds.b		1			* bit 0 : -r option

		.align		4

		.end		p8emu_start

