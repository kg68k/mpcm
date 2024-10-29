*=======================================================
*
*	１６ｂｉｔＰＣＭ 15.6kHz変換
*
*=======================================================

PCM16_0104:
PCM16_0103:
PCM16_0102:
PCM16_0203:
PCM16_0101:
		move.w		CH_VOL(a5),d5		* d5.w = PCM VOLUME

		tst.b		CH_KEY_STAT(a5)		* keyon=$01 keyoff=$80 non=$00
		bmi		PCM16_0101_keyoff
		bne		PCM16_0101_keyon

*		通常の処理
		movea.l		CH_PCM_ADR(a5),a0	* a0.l = PCMアドレス
		movea.l		CH_TRAP_ADR(a5),a3	* a3.l = トラップアドレス
		movea.l		CH_TRAP_ROUTINE(a5),a4	* a4.l = トラップ時の処理ルーチン

		movea.l		CH_JMP_ADR2(a5),a6
		jmp		(a6)

*		キーオンの処理
PCM16_0101_keyon:
		clr.b		CH_KEY_STAT(a5)		* KEY 状態リセット

		clr.w		CH_PITCH_CTR(a5)	* ピッチカウンタクリア
		movea.l		CH_TOP_ADR(a5),a0	* a0.l = PCM先頭アドレス

		move.l		CH_LPTIME(a5),d7	* ループ処理があるか？
		moveq.l		#1,d1
		cmp.l		d1,d7			* cmpi.l より4clk速い
		beq		1f
		move.l		d7,CH_LPTIME_CTR(a5)	* ループ回数カウンタ初期化
		movea.l		CH_LPEND_ADR(a5),a3	* a3.l = ループ終了アドレス
		lea.l		PCM16_LPEND,a4		* a4.l = ループ終了処理アドレス
		move.l		a3,CH_TRAP_ADR(a5)
		move.l		a4,CH_TRAP_ROUTINE(a5)	* トラップ情報ををワークに保存

		movea.l		CH_JMP_ADR2(a5),a6
		jmp		(a6)

1:		movea.l		CH_END_ADR(a5),a3	* a3.l = 16bit PCMデータ終了アドレス
		lea.l		PCM16_END,a4		* a4.l = データ終了処理アドレス
		move.l		a3,CH_TRAP_ADR(a5)
		move.l		a4,CH_TRAP_ROUTINE(a5)	* トラップ情報ををワークに保存

		movea.l		CH_JMP_ADR2(a5),a6
		jmp		(a6)

*		キーオフの処理
PCM16_0101_keyoff:
		clr.b		CH_KEY_STAT(a5)		* KEY 状態リセット
		clr.b		CH_PLAY_FLAG(a5)	* 演奏終了
		jmp		make_keyoff_PCM		* 消音PCM展開

*=======================================================

PCM16_0101_mac	macro		_vol

		move.l		#MIX_SIZE*4-2,d6
		add.l		a0,d6
		cmp.l		a3,d6
		bcs		@f			* 今回の処理中にはトラップしない

		moveq.l		#MIX_SIZE*2-1-1,d6
2:		cmpa.l		a3,a0			* トラップアドレス判定
		bcs		1f
		jsr		(a4)			* トラップ!
1:		move.w		(a0)+,d0		* PCMデータ取り込み
		VOLUME		_vol,d0,d2
		add.w		d0,(a1)+
		dbra		d6,2b

*		ラストの１回
		cmpa.l		a3,a0
		bcs		1f
		jsr		(a4)			* トラップ!
1:		move.w		(a0)+,d0		* PCMデータ取り込み
		move.w		d0,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d0.w
		VOLUME		_vol,d0,d2
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+

		move.l		a0,CH_PCM_ADR(a5)	* PCMアドレス = a0.l

		rts

		* トラップ無し
@@:		moveq.l		#MIX_SIZE*2-1-1,d6
2:		move.w		(a0)+,d0		* PCMデータ取り込み
		VOLUME		_vol,d0,d2
		add.w		d0,(a1)+
		dbra		d6,2b

*		ラストの１回
		move.w		(a0)+,d0		* PCMデータ取り込み
		move.w		d0,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d0.w
		VOLUME		_vol,d0,d2
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+

		move.l		a0,CH_PCM_ADR(a5)	* PCMアドレス = a0.l

		rts

		endm

*=======================================================

PCM16_0101_v00:PCM16_0101_mac	0
PCM16_0101_v01:PCM16_0101_mac	1
PCM16_0101_v02:PCM16_0101_mac	2
PCM16_0101_v03:PCM16_0101_mac	3
PCM16_0101_v04:PCM16_0101_mac	4
PCM16_0101_v05:PCM16_0101_mac	5
PCM16_0101_v06:PCM16_0101_mac	6
PCM16_0101_v07:PCM16_0101_mac	7
PCM16_0101_v08:PCM16_0101_mac	8
PCM16_0101_v09:PCM16_0101_mac	9
PCM16_0101_v10:PCM16_0101_mac	10
PCM16_0101_v11:PCM16_0101_mac	11
PCM16_0101_v12:PCM16_0101_mac	12
PCM16_0101_v13:PCM16_0101_mac	13
PCM16_0101_v14:PCM16_0101_mac	14
PCM16_0101_v15:PCM16_0101_mac	15
PCM16_0101_vnn:PCM16_0101_mac	'n'
PCM16_0101_non:PCM16_0101_mac	'x'
