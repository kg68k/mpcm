*=======================================================
*
*	ＡＤＰＣＭ－＞ＰＣＭ 低音程変換
*
*=======================================================

AtoP_low:
		move.w		CH_PITCH+2(a5),d3	* d3.w = ADPCM音程下位16bit
		move.w		CH_VOL(a5),d5		* d5.w = ADPCM VOLUME

		tst.b		CH_KEY_STAT(a5)		* keyon=$01 keyoff=$80 non=$00
		bmi		AtoP_low_keyoff
		bne		AtoP_low_keyon

*		通常の処理
		move.w		CH_LAST_PCM(a5),d0	* d0.w = 前回変換終了時のPCM値
		move.w		CH_AtoP_Y(a5),d1	* d1.w = PCM予測値
		move.b		CH_ODDEVEN(a5),d2	* d2.b = ODD/EVEN FLAG
		move.w		CH_PITCH_CTR(a5),d4	* d4.w = 音程カウンタ
		movea.l		CH_PCM_ADR(a5),a0	* a0.l = ADPCMアドレス
		movea.l		CH_AtoP_X(a5),a2	* a2.l = ADPCM->PCM変換テーブルアドレス
		movea.l		CH_TRAP_ADR(a5),a3	* a3.l = 変換中のトラップアドレス
		movea.l		CH_TRAP_ROUTINE(a5),a4	* a4.l = トラップ時の処理ルーチン

		movea.l		CH_JMP_ADR2(a5),a6
		jmp		(a6)

*		キーオンの処理
AtoP_low_keyon:
		clr.b		CH_KEY_STAT(a5)		* KEY 状態リセット

		moveq.l		#0,d0			* d0.w = 前回変換終了時のPCM値
		moveq.l		#0,d1			* d1.w = PCM予測値
		moveq.l		#-1,d2			* d2.b = ODD/EVEN FLAG リセット
		move.w		d3,d4			* d4.w = 音程カウンタ
		neg.w		d4			* d4.w =-増分(1回目でPCM変換するため)
		movea.l		CH_TOP_ADR(a5),a0	* a0.l = ADPCM先頭アドレス
		movea.l		#AtoP_tbl,a2		* a2.l = 変換テーブル

		move.l		CH_LPTIME(a5),d7	* ループ処理をするか
		moveq.l		#1,d6
		cmp.l		d6,d7			* cmpi.l より4clk速い
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
AtoP_low_keyoff:
		clr.b		CH_KEY_STAT(a5)		* KEY 状態リセット
		clr.b		CH_PLAY_FLAG(a5)	* 演奏終了
		jmp		make_keyoff_PCM		* 消音PCM展開

*=======================================================

AtoP_low_mac	macro		_vol

		move.w		d3,a6

		move.l		CH_TPCNST(a5),d6
		add.l		a0,d6
		cmp.l		a3,d6
		bcs		@f			* トラップ判定無しへ

		moveq.l		#MIX_SIZE*2-1,d3	* ADPCM -> PCM 変換

4:		add.w		a6,d4			* 音程カウンタ += 音程
		bcc		3f
		neg.b		d2
		bmi		2f
		cmpa.l		a3,a0			* トラップにかかった？
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		bra		3f
2:		move.w		d1,d0
3:	.if	_vol=8
		add.w		d0,(a1)+
	.else
		move.w		d0,d7
		VOLUME		_vol,d7,d6
		add.w		d7,(a1)+
	.endif
		dbra		d3,4b

		move.w		d0,CH_LAST_PCM(a5)	* d0.w = 前回変換終了時のPCM値
	.if	_vol=8
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
	.else
		move.w		d7,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
	.endif
		move.w		d1,CH_AtoP_Y(a5)	* d1.w = PCM予測値
		move.b		d2,CH_ODDEVEN(a5)	* d2.b = ODD/EVEN FLAG
		move.w		d4,CH_PITCH_CTR(a5)	* d4.w = 音程カウンタ
		move.l		a0,CH_PCM_ADR(a5)	* a0.l = ADPCMアドレス
		move.l		a2,CH_AtoP_X(a5)	* a2.l = ADPCM->PCM変換テーブルアドレス

		rts

@@:
		moveq.l		#MIX_SIZE*2-1,d3	* ADPCM -> PCM 変換

4:		add.w		a6,d4			* 音程カウンタ += 音程
		bcc		3f
		neg.b		d2
		bmi		2f
		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		bra		3f
2:		move.w		d1,d0
3:	.if	_vol=8
		add.w		d0,(a1)+
	.else
		move.w		d0,d7
		VOLUME		_vol,d7,d6
		add.w		d7,(a1)+
	.endif
		dbra		d3,4b

		move.w		d0,CH_LAST_PCM(a5)	* d0.w = 前回変換終了時のPCM値
	.if	_vol=8
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
	.else
		move.w		d7,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
	.endif
		move.w		d1,CH_AtoP_Y(a5)	* d1.w = PCM予測値
		move.b		d2,CH_ODDEVEN(a5)	* d2.b = ODD/EVEN FLAG
		move.w		d4,CH_PITCH_CTR(a5)	* d4.w = 音程カウンタ
		move.l		a0,CH_PCM_ADR(a5)	* a0.l = ADPCMアドレス
		move.l		a2,CH_AtoP_X(a5)	* a2.l = ADPCM->PCM変換テーブルアドレス

		rts

		endm

*=======================================================

AtoP_low_v00:	AtoP_low_mac	0
AtoP_low_v01:	AtoP_low_mac	1
AtoP_low_v02:	AtoP_low_mac	2
AtoP_low_v03:	AtoP_low_mac	3
AtoP_low_v04:	AtoP_low_mac	4
AtoP_low_v05:	AtoP_low_mac	5
AtoP_low_v06:	AtoP_low_mac	6
AtoP_low_v07:	AtoP_low_mac	7
AtoP_low_v08:	AtoP_low_mac	8
AtoP_low_v09:	AtoP_low_mac	9
AtoP_low_v10:	AtoP_low_mac	10
AtoP_low_v11:	AtoP_low_mac	11
AtoP_low_v12:	AtoP_low_mac	12
AtoP_low_v13:	AtoP_low_mac	13
AtoP_low_v14:	AtoP_low_mac	14
AtoP_low_v15:	AtoP_low_mac	15
AtoP_low_vnn:	AtoP_low_mac	'n'
AtoP_low_non:	AtoP_low_mac	'x'

