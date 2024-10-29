*=======================================================
*
*	８ｂｉｔＰＣＭ高音程変換
*
*=======================================================

PCM8_high:
		move.w		CH_PITCH(a5),d1		* d1.w = ピッチ上位16bit
		move.w		CH_PITCH+2(a5),d3	* d3.w = ピッチ下位16bit
		moveq.l		#0,d2			* d2.w = ピッチカウンタ上位16bit
		move.w		CH_VOL(a5),d5		* d5.w = PCM VOLUME

		tst.b		CH_KEY_STAT(a5)		* keyon=$01 keyoff=$80 non=$00
		bmi		PCM8_high_keyoff
		bne		PCM8_high_keyon

*		通常の処理
		move.w		CH_PITCH_CTR(a5),d4	* d4.w = 音程カウンタ下位16bit
		movea.l		CH_PCM_ADR(a5),a0	* a0.l = PCMアドレス
		movea.l		CH_TRAP_ADR(a5),a3	* a3.l = トラップアドレス
		movea.l		CH_TRAP_ROUTINE(a5),a4	* a4.l = トラップ時の処理ルーチン

		movea.l		CH_JMP_ADR2(a5),a6
		jmp		(a6)

*		キーオンの処理
PCM8_high_keyon:
		clr.b		CH_KEY_STAT(a5)		* KEY 状態リセット

		moveq.l		#0,d4			* d4.l = 音程カウンタ
		movea.l		CH_TOP_ADR(a5),a0	* a0.l = PCM先頭アドレス

		move.l		CH_LPTIME(a5),d7	* ループ処理があるか？
		moveq.l		#1,d6
		cmp.l		d6,d7			* cmpi.l より4clk速い
		beq		1f
		move.l		d7,CH_LPTIME_CTR(a5)	* ループ回数カウンタ初期化
		movea.l		CH_LPEND_ADR(a5),a3	* a3.l = ループ終了アドレス
		lea.l		PCM8_LPEND,a4		* a4.l = ループ終了処理アドレス
		move.l		a3,CH_TRAP_ADR(a5)
		move.l		a4,CH_TRAP_ROUTINE(a5)	* トラップ情報ををワークに保存

		movea.l		CH_JMP_ADR2(a5),a6
		jmp		(a6)

1:		movea.l		CH_END_ADR(a5),a3	* a3.l = 16bit PCMデータ終了アドレス
		lea.l		PCM8_END,a4		* a4.l = データ終了処理アドレス
		move.l		a3,CH_TRAP_ADR(a5)
		move.l		a4,CH_TRAP_ROUTINE(a5)	* トラップ情報ををワークに保存

		movea.l		CH_JMP_ADR2(a5),a6
		jmp		(a6)

*		キーオフの処理
PCM8_high_keyoff:
		clr.b		CH_KEY_STAT(a5)		* KEY 状態リセット
		clr.b		CH_PLAY_FLAG(a5)	* 演奏終了
		jmp		make_keyoff_PCM		* 消音PCM展開

*=======================================================

PCM8_high_mac	macro		_vol

		move.l		CH_TPCNST(a5),d6
		add.l		a0,d6
		cmp.l		a3,d6
		bcs		@f

*		トラップ判定あり

		moveq.l		#MIX_SIZE*2-1-1,d6

2:		add.w		d3,d4			* PITCH_CTR下位16bit += PITCH下位16bit
		addx.w		d1,d2			* d2.w = d2.w + d1.w + CF
		adda.w		d2,a0			* PCMアドレス更新
		clr.w		d2			* PITCH_CTRの上位16bitクリア

		cmpa.l		a3,a0			* トラップアドレス判定
		bcs		1f
		jsr		(a4)			* トラップ!
1:		move.b		(a0),d0			* PCMデータ取り込み
		ext.w		d0			* 符号拡張
		VOLUME		_vol,d0,d7
		add.w		d0,(a1)+

		dbra		d6,2b

*		ラストの１回
		add.w		d3,d4			* PITCH_CTR下位16bit += PITCH下位16bit
		addx.w		d1,d2			* d2.w = d2.w + d1.w + CF
		adda.w		d2,a0			* PCMアドレス更新

		cmpa.l		a3,a0
		bcs		1f
		jsr		(a4)			* トラップ!
1:		move.b		(a0),d0			* PCMデータ取り込み
		ext.w		d0			* 符号拡張
		move.w		d0,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d0.w
		VOLUME		_vol,d0,d7
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+

		move.w		d4,CH_PITCH_CTR(a5)	* 音程カウンタ下位ワード = d4.w
		move.l		a0,CH_PCM_ADR(a5)	* PCMアドレス = a0.l

		rts


		* トラップ無しの変換

@@:		moveq.l		#MIX_SIZE*2-1-1,d6

2:		add.w		d3,d4			* PITCH_CTR下位16bit += PITCH下位16bit
		addx.w		d1,d2			* d2.w = d2.w + d1.w + CF
		adda.w		d2,a0			* PCMアドレス更新
		clr.w		d2			* PITCH_CTRの上位16bitクリア

		move.b		(a0),d0			* PCMデータ取り込み
		ext.w		d0			* 符号拡張
		VOLUME		_vol,d0,d7
		add.w		d0,(a1)+

		dbra		d6,2b

*		ラストの１回
		add.w		d3,d4			* PITCH_CTR下位16bit += PITCH下位16bit
		addx.w		d1,d2			* d2.w = d2.w + d1.w + CF
		adda.w		d2,a0			* PCMアドレス更新

		move.b		(a0),d0			* PCMデータ取り込み
		ext.w		d0			* 符号拡張
		move.w		d0,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d0.w
		VOLUME		_vol,d0,d7
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+

		move.w		d4,CH_PITCH_CTR(a5)	* 音程カウンタ下位ワード = d4.w
		move.l		a0,CH_PCM_ADR(a5)	* PCMアドレス = a0.l

		rts
  
		endm

*=======================================================

PCM8_high_v00:	PCM8_high_mac	0
PCM8_high_v01:	PCM8_high_mac	1
PCM8_high_v02:	PCM8_high_mac	2
PCM8_high_v03:	PCM8_high_mac	3
PCM8_high_v04:	PCM8_high_mac	4
PCM8_high_v05:	PCM8_high_mac	5
PCM8_high_v06:	PCM8_high_mac	6
PCM8_high_v07:	PCM8_high_mac	7
PCM8_high_v08:	PCM8_high_mac	8
PCM8_high_v09:	PCM8_high_mac	9
PCM8_high_v10:	PCM8_high_mac	10
PCM8_high_v11:	PCM8_high_mac	11
PCM8_high_v12:	PCM8_high_mac	12
PCM8_high_v13:	PCM8_high_mac	13
PCM8_high_v14:	PCM8_high_mac	14
PCM8_high_v15:	PCM8_high_mac	15
PCM8_high_vnn:	PCM8_high_mac	'n'
PCM8_high_non:	PCM8_high_mac	'x'
