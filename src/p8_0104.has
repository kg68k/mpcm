*=======================================================
*
*	８ｂｉｔＰＣＭ 3.9kHz変換
*
*=======================================================

PCM8_0104_mac	macro		_vol

		moveq.l		#MIX_SIZE/2-1,d6	* 48 * 2 = 96 <= 127 で moveq OK
		add.l		a0,d6
		cmp.l		a3,d6
		bcs		@f			* 今回の処理中にはトラップしない

		* トラップ判定付きの変換
		moveq.l		#MIX_SIZE/2-1-1,d6
2:		cmpa.l		a3,a0			* トラップアドレス判定
		bcs		1f
		jsr		(a4)			* トラップ!
1:		move.b		(a0)+,d0		* PCMデータ取り込み
		ext.w		d0			* 符号拡張
		VOLUME		_vol,d0,d2
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		dbra		d6,2b

*		ラストの１回
		cmpa.l		a3,a0
		bcs		1f
		jsr		(a4)			* トラップ!
1:		move.b		(a0)+,d0		* PCMデータ取り込み
		ext.w		d0			* 符号拡張
		move.w		d0,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d0.w
		VOLUME		_vol,d0,d2
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+

		move.l		a0,CH_PCM_ADR(a5)	* PCMアドレス = a0.l

		rts


		* トラップ無しの変換

@@:		moveq.l		#MIX_SIZE/2-1-1,d6
2:		move.b		(a0)+,d0		* PCMデータ取り込み
		ext.w		d0			* 符号拡張
		VOLUME		_vol,d0,d2
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		dbra		d6,2b

*		ラストの１回
		move.b		(a0)+,d0		* PCMデータ取り込み
		ext.w		d0			* 符号拡張
		move.w		d0,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d0.w
		VOLUME		_vol,d0,d2
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+

		move.l		a0,CH_PCM_ADR(a5)	* PCMアドレス = a0.l

		rts
  
		endm

*=======================================================

PCM8_0104_v00:	PCM8_0104_mac	0
PCM8_0104_v01:	PCM8_0104_mac	1
PCM8_0104_v02:	PCM8_0104_mac	2
PCM8_0104_v03:	PCM8_0104_mac	3
PCM8_0104_v04:	PCM8_0104_mac	4
PCM8_0104_v05:	PCM8_0104_mac	5
PCM8_0104_v06:	PCM8_0104_mac	6
PCM8_0104_v07:	PCM8_0104_mac	7
PCM8_0104_v08:	PCM8_0104_mac	8
PCM8_0104_v09:	PCM8_0104_mac	9
PCM8_0104_v10:	PCM8_0104_mac	10
PCM8_0104_v11:	PCM8_0104_mac	11
PCM8_0104_v12:	PCM8_0104_mac	12
PCM8_0104_v13:	PCM8_0104_mac	13
PCM8_0104_v14:	PCM8_0104_mac	14
PCM8_0104_v15:	PCM8_0104_mac	15
PCM8_0104_vnn:	PCM8_0104_mac	'n'
PCM8_0104_non:	PCM8_0104_mac	'x'
