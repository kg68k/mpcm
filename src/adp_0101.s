*=======================================================
*
*	ＡＤＰＣＭ－＞ＰＣＭ 15.6kHz変換
*
*=======================================================

AtoP15n		macro		_X,_vol

		local		next

	.if	_X
		cmpa.l		a3,a0			* トラップにかかった？
		bcs		next
		jsr		(a4)			* トラップ処理
	.endif
next:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
	.if	_vol=8
		add.w		d1,(a1)+
	.else
		move.w		d1,d0			* (4)
		VOLUME		_vol,d0,d2
		add.w		d0,(a1)+
	.endif
		add.w		256*2(a2),d1		* (12)
	.if	_vol=8
		add.w		d1,(a1)+
	.else
		move.w		d1,d0			* (4)
		VOLUME		_vol,d0,d2
		add.w		d0,(a1)+
	.endif
		adda.w		256*2*2(a2),a2		* (16)

		endm

*=======================================================

AtoP_0101:
AtoP_0203:
AtoP_0102:
AtoP_0103:
AtoP_0104:
		move.w		CH_VOL(a5),d5		* d5.w = ADPCM VOLUME

		tst.b		CH_KEY_STAT(a5)		* keyon=$01 keyoff=$80 non=$00
		bmi		AtoP_0101_keyoff
		bne		AtoP_0101_keyon

*		通常の処理
		move.w		CH_AtoP_Y(a5),d1	* d1.w = PCM予測値
		movea.l		CH_PCM_ADR(a5),a0	* a0.l = ADPCMアドレス
		movea.l		CH_AtoP_X(a5),a2	* a2.l = ADPCM->PCM変換テーブルアドレス
		movea.l		CH_TRAP_ADR(a5),a3	* a3.l = 変換中のトラップアドレス
		movea.l		CH_TRAP_ROUTINE(a5),a4	* a4.l = トラップ時の処理ルーチン

		movea.l		CH_JMP_ADR2(a5),a6
		jmp		(a6)

*		キーオンの処理
AtoP_0101_keyon:
		clr.b		CH_KEY_STAT(a5)		* KEY 状態リセット

		moveq.l		#0,d1			* d1.w = PCM予測値
		st.b		CH_ODDEVEN(a5)		* ODD/EVEN FLAG リセット
		clr.w		CH_PITCH_CTR(a5)	* 音程カウンタクリア
		movea.l		CH_TOP_ADR(a5),a0	* a0.l = ADPCM先頭アドレス
		movea.l		#AtoP_tbl,a2		* a2.l = 変換テーブル

		move.l		CH_LPTIME(a5),d7	* ループ処理をするか？
		moveq.l		#1,d2
		cmp.l		d2,d7			* cmpi.l より4clk速い
		beq		1f
		move.l		d7,CH_LPTIME_CTR(a5)	* ループ回数カウンタ初期化
		movea.l		CH_LPSTART_ADR(a5),a3	* a3.l = ループスタートアドレス
		lea.l		AtoP_LOOP,a4		* a4.l = ループスタート処理アドレス
		move.l		a3,CH_TRAP_ADR(a5)
		move.l		a4,CH_TRAP_ROUTINE(a5)	* トラップ情報ををワークに保存

		movea.l		CH_JMP_ADR2(a5),a6
		jmp		(a6)

1:		movea.l		CH_END_ADR(a5),a3	* a3.l = ADPCMデータ終了アドレス
		lea.l		AtoP_END,a4		* a4.l = データ終了処理アドレス
		move.l		a3,CH_TRAP_ADR(a5)
		move.l		a4,CH_TRAP_ROUTINE(a5)	* トラップ情報ををワークに保存

		movea.l		CH_JMP_ADR2(a5),a6
		jmp		(a6)

*		キーオフの処理
AtoP_0101_keyoff:
		clr.b		CH_KEY_STAT(a5)		* KEY 状態リセット
		clr.b		CH_PLAY_FLAG(a5)	* 演奏終了
		jmp		make_keyoff_PCM		* 消音PCM展開

*=======================================================

AtoP_0101_mac	macro		_vol

		local		ADPCM_odd

		tst.b		CH_ODDEVEN(a5)		* ODD/EVEN FLAG	のチェック
		bpl		ADPCM_odd		* 変換が1ADPCMずれる場合

*		前が奇数番目のADPCMを処理していた場合
		moveq.l		#MIX_SIZE-1,d2		* (4) 今回の処理中になんらかの
		add.l		a0,d2			* (8) トラップが発生するか調べる
		cmp.l		a3,d2			* (6)
		bcs		@f			* (10)

*		トラップ判定あり
		moveq.l		#MIX_SIZE-1,d6		* ADPCM -> PCM 変換
1:		AtoP15n		1,_vol
		dbra		d6,1b
		move.w		d1,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d1.w
	.if	_vol=8
		move.w		d1,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
	.else
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
	.endif
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		rts

*		トラップ判定無し
@@:		moveq.l		#MIX_SIZE-1,d6		* ADPCM -> PCM 変換
1:		AtoP15n		0,_vol
		dbra		d6,1b
		move.w		d1,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d1.w
	.if	_vol=8
		move.w		d1,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
	.else
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
	.endif
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		rts

*		前が偶数番目のADPCMを処理していた場合
ADPCM_odd:	moveq.l		#MIX_SIZE-1,d2		* (4) 今回の処理中になんらかの
		add.l		a0,d2			* (8) トラップが発生するか調べる
		cmp.l		a3,d2			* (6)
		bcs		@f			* (10)

*		トラップ判定あり
	.if	_vol=8
		add.w		d1,(a1)+
	.else
		move.w		d1,d0
		VOLUME		_vol,d0,d2
		add.w		d0,(a1)+
	.endif
		moveq.l		#MIX_SIZE-1-1,d6	* ADPCM -> PCM 変換
1:		AtoP15n		1,_vol
		dbra		d6,1b
							* ラストの1回
		cmpa.l		a3,a0			* トラップにかかった？
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d1.w
	.if	_vol=8
		move.w		d1,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d1,(a1)+
	.else
		move.w		d1,d0			* (4)
		VOLUME		_vol,d0,d2
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+
	.endif
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		rts

*		トラップ判定無し
@@:
	.if	_vol=8
		add.w		d1,(a1)+
	.else
		move.w		d1,d0
		VOLUME		_vol,d0,d2
		add.w		d0,(a1)+
	.endif
		moveq.l		#MIX_SIZE-1-1,d6	* ADPCM -> PCM 変換
1:		AtoP15n		0,_vol
		dbra		d6,1b
							* ラストの1回
		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d1.w
	.if	_vol=8
		move.w		d1,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d1,(a1)+
	.else
		move.w		d1,d0			* (4)
		VOLUME		_vol,d0,d2
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+
	.endif
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		rts

		endm

*=======================================================

AtoP_0101_v00:	AtoP_0101_mac	0
AtoP_0101_v01:	AtoP_0101_mac	1
AtoP_0101_v02:	AtoP_0101_mac	2
AtoP_0101_v03:	AtoP_0101_mac	3
AtoP_0101_v04:	AtoP_0101_mac	4
AtoP_0101_v05:	AtoP_0101_mac	5
AtoP_0101_v06:	AtoP_0101_mac	6
AtoP_0101_v07:	AtoP_0101_mac	7
AtoP_0101_v08:	AtoP_0101_mac	8
AtoP_0101_v09:	AtoP_0101_mac	9
AtoP_0101_v10:	AtoP_0101_mac	10
AtoP_0101_v11:	AtoP_0101_mac	11
AtoP_0101_v12:	AtoP_0101_mac	12
AtoP_0101_v13:	AtoP_0101_mac	13
AtoP_0101_v14:	AtoP_0101_mac	14
AtoP_0101_v15:	AtoP_0101_mac	15
AtoP_0101_vnn:	AtoP_0101_mac	'n'
AtoP_0101_non:	AtoP_0101_mac	'x'
