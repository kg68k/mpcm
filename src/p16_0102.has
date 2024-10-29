*=======================================================
*
*	１６ｂｉｔＰＣＭ 7.8kHz変換
*
*=======================================================

PCM16_0102_mac	macro		_vol

		move.l		#MIX_SIZE*2-2,d6
		add.l		a0,d6
		cmp.l		a3,d6
		bcs		@f			* 今回の処理中にはトラップしない

		moveq.l		#MIX_SIZE-1-1,d6
2:		cmpa.l		a3,a0			* トラップアドレス判定
		bcs		1f
		jsr		(a4)			* トラップ!
1:		move.w		(a0)+,d0		* PCMデータ取り込み
		VOLUME		_vol,d0,d2
		add.w		d0,(a1)+
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
		add.w		d0,(a1)+

		move.l		a0,CH_PCM_ADR(a5)	* PCMアドレス = a0.l

		rts

		* トラップ無し
@@:		moveq.l		#MIX_SIZE-1-1,d6
2:		move.w		(a0)+,d0		* PCMデータ取り込み
		VOLUME		_vol,d0,d2
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		dbra		d6,2b

*		ラストの１回
		move.w		(a0)+,d0		* PCMデータ取り込み
		move.w		d0,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d0.w
		VOLUME		_vol,d0,d2
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+
		add.w		d0,(a1)+

		move.l		a0,CH_PCM_ADR(a5)	* PCMアドレス = a0.l
		rts

		endm

*=======================================================

PCM16_0102_v00:	PCM16_0102_mac	0
PCM16_0102_v01:	PCM16_0102_mac	1
PCM16_0102_v02:	PCM16_0102_mac	2
PCM16_0102_v03:	PCM16_0102_mac	3
PCM16_0102_v04:	PCM16_0102_mac	4
PCM16_0102_v05:	PCM16_0102_mac	5
PCM16_0102_v06:	PCM16_0102_mac	6
PCM16_0102_v07:	PCM16_0102_mac	7
PCM16_0102_v08:	PCM16_0102_mac	8
PCM16_0102_v09:	PCM16_0102_mac	9
PCM16_0102_v10:	PCM16_0102_mac	10
PCM16_0102_v11:	PCM16_0102_mac	11
PCM16_0102_v12:	PCM16_0102_mac	12
PCM16_0102_v13:	PCM16_0102_mac	13
PCM16_0102_v14:	PCM16_0102_mac	14
PCM16_0102_v15:	PCM16_0102_mac	15
PCM16_0102_vnn:	PCM16_0102_mac	'n'
PCM16_0102_non:	PCM16_0102_mac	'x'
