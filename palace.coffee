pulse =
	alive: yes
	#lastResort: []
#requestFilmFrame = (ff) ->
filmReel = (ff) ->
	ltt = 0
	ffprocess = (tt) ->
		return if not pulse.alive
		#if ltt is 0 or (tt-ltt) > 0.04171 # 23.97fps
		if ltt is 0 or (tt-ltt) > 41.71 # heh, I meant miliseconds
			ltt = tt
			ff tt
		requestAnimationFrame ffprocess
	requestAnimationFrame ffprocess
root = document.body

# useful block: 12076948
# curiously small pyramid: 12077380
# loads of pyramids: 12077469
# LOTSA ducks: 12077996
# BUSTED pyramid: 12078602 (now fixed!)
# Super lovely: 12080350
# Nice NFT exhibit: 12080425
# Adorable early exhibit: 7280024
# Beautiful block: 12081620

#queueMicrotask = requestAnimationFrame if not window.queueMicrotask

[l3d,lxo] = root.querySelectorAll '[pr]'

#

#bloverride = no
#bloverride = 7280024

# super mega ultra cache
window.SMUC = {}
cache_only = no
###
bloverride = no
cache_only = yes
# ###

# let let let
stage =
	ren: null
	scn: null
	ggr: null
	cam: null
	mtl: {}
	trn: 0
#
# Resize handling
addEventListener 'resize',(ev) -> sizeAndRezize() if stage.ren
# Resize handling.
#
display_cap = 1920 * 1080 # firefox melts into the floor if you fullscreen these things without capping the res
rawMaterials = ->
	stage.mtl.nice = new THREE.MeshPhongMaterial
		color: 0xFFFFFF
		#side: THREE.DoubleSide
		flatShading: yes
	stage.mtl.nicer = new THREE.MeshPhongMaterial
		color: 0xFFFFFF
		emissive: 0x225522
		#side: THREE.DoubleSide
		flatShading: yes
	stage.mtl.alsonice = new THREE.MeshPhongMaterial
		color: 0xFFFFFF
		emissive: 0x669977
		#side: THREE.DoubleSide
		flatShading: yes
	stage.mtl.sparkle = new THREE.MeshPhongMaterial
		color: 0x666666
		emissive: 0x88DD00
		#emissive: 0x99CC00
		#side: THREE.DoubleSide
		flatShading: yes
	#
	# Shader baseline from https://threejs.org/docs/#api/en/renderers/webgl/WebGLProgram
	stage.mtl.shade = new THREE.ShaderMaterial
		# referenced some old code to remember how I used to access the UV co-ordinate from the fragment shader
		# see screenshot -->
		vertexShader: """
			varying vec4 sendpos;
			varying vec2 senduv;
			void main() {
				gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
				sendpos = gl_Position;
				senduv = uv;
			}
		"""
		# This is deliberately the most elemental fragment shader imaginable.
		# Didn't use sendpos in the end.
		fragmentShader: """
			varying vec4 sendpos;
			varying vec2 senduv;
			void main () {
				gl_FragColor.rgb = vec3(fract(senduv.xy),1.0);
				//gl_FragColor.rgb = sendpos.rgb;
			}
		"""
sizeAndRezize = ->
	ww = l3d.offsetWidth
	hh = l3d.offsetHeight
	#
	###
	# I didn't code this right, and yanno, if you wanna fullscreen a 3d
	#  browser scene, please feel at home.
	pc = ww * hh * devicePixelRatio
	mod = if pc > display_cap
		display_cap / pc # I probably have this backwards. Update: I did.
	else
		1
	###
	mod = 1
	#
	stage.ren.setPixelRatio devicePixelRatio
	stage.ren.setSize ww * mod,hh * mod
	#
	#stage.cam.dispose() if stage.cam # apparently that's not needed
	#
	# These three lines initially copied verbatim
	stage.cam = new THREE.PerspectiveCamera 35,ww/hh,0.1,2000
	stage.cam.position.set 0,-200,5
	stage.cam.rotation.x = (Math.PI/2) * 0.97
	#
sceneStart = ->
	# I began this setup function based heavily on old boiler plate
	# I used to use; it's mutated a decent bit.
	#
	stage.ren = new THREE.WebGLRenderer
	sizeAndRezize()
	#
	stage.ren.domElement.style.width = '100%'
	stage.ren.domElement.style.height = '100%'
	l3d.appendChild stage.ren.domElement
	#
	stage.scn = new THREE.Scene
	stage.ggr = new THREE.Group
	#
	# these need work.
	stage.scn.add new THREE.AmbientLight 0x6622FF
	#
	light = new THREE.DirectionalLight 0x5566DD, 0.7 
	light.position.set -100,0,50
	stage.scn.add light
	#
	light = new THREE.DirectionalLight 0x000099, 1.0
	light.position.set 0,0,50
	stage.ggr.add light # add it to the spinning group
	#
	light = new THREE.DirectionalLight 0x332255, 1.0
	light.position.set 0,0,-50
	stage.ggr.add light # add it to the spinning group
	#
	stage.scn.add stage.ggr
#
addBaseline = (blk) ->
	stage.trn = blk.gasUsed * 0.00000000004
	# base as giant inverted pyramid
	# doesn't use hash for anything yet. hopefully there's time.
	shp = new THREE.ConeGeometry 50,40,4
	#oba = new THREE.Mesh shp,stage.mtl.nice
	oba = new THREE.Mesh shp,stage.mtl.shade
	oba.rotation.x = -Math.PI/2
	oba.position.z = -40
	#
	stage.ggr.add oba
# ref:
#
# thx https://threejs.org/docs/?q=geometry#api/en/core/BufferGeometry
# buffer geometry.. too hard. Switching to built-in shapes.
###
bg = new THREE.BufferGeometry
vx = new Float32Array [
	-8.0, -8.0,  8.0,
	8.0, -8.0,  8.0,
	8.0,  8.0,  8.0,

	8.0,  8.0,  8.0,
	-8.0,  8.0,  8.0,
	-8.0, -8.0,  8.0
]
bg.setAttribute 'position',new THREE.BufferAttribute vx,3
oba = new THREE.Mesh bg,stage.mtl.nice
oba.position = new THREE.Vector3 0,0,0
stage.ggr.add oba
###
#
addDiamond = (ttl,tna,addy,tstate) ->
	#
	#shp = new THREE.BoxGeometry  1,2,1
	umtl = switch tstate
		#when 2 then stage.mtl.sparkle
		#when 1 then stage.mtl.nicer
		#else stage.mtl.nice
		when 2 then stage.mtl.alsonice
		when 1 then stage.mtl.nice
		else stage.mtl.nice
	#
	shp = new THREE.OctahedronGeometry  1,0
	oba = new THREE.Mesh shp,umtl
	oba.rotation.x = Math.PI/2 # wouldn't it have been easier if I just didn't rotate the camera in the first place? Yes.
	oba.rotation.y = Math.PI/4 
	oba.position.z = -20 + 1
	szmod = 1
	#
	# bring the high bytes down to the range of -50 to 50 as if the address is two 10byte co-ords
	oba.position.x = 0.5 * 0.39 * (-0x80 + parseInt addy.substr(2,2),16)
	oba.position.y = 0.5 * 0.39 * (-0x80 + parseInt addy.substr(22,2),16)
	oba.position.z += tna.gasPrice * tna.gas * 0.000000000000002
	#
	szmod *= Math.min 1,200/ttl
	oba.scale.x = szmod
	oba.scale.y = szmod
	oba.scale.z = szmod
	#
	stage.ggr.add oba
	#
	oba.userData.tna = tna
addPyramid = (ttl,tna,addy,code,tstate) ->
	#
	umtl = switch tstate
		#when 2 then stage.mtl.sparkle
		#when 1 then stage.mtl.nicer
		#else stage.mtl.nice
		when 2 then stage.mtl.nicer # DIFFERENT for pyramids; they catch the light better
		when 1 then stage.mtl.nice
		else stage.mtl.nice
	#
	shp = new THREE.ConeGeometry  5,4,4
	oba = new THREE.Mesh shp,umtl
	oba.rotation.x = Math.PI/2 # wouldn't it have been easier if I just didn't rotate the camera in the first place? Yes.
	#
	szmod = code.length / 9000 # more bytecode => bigger pyramid
	szmod *= 0.5 # they're just too big
	szmod *= Math.min 1,200/ttl
	szmod = Math.max szmod,0.5
	#
	# bring the high bytes down to the range of -50 to 50 as if the address is two 10byte co-ords
	oba.position.x = 0.5 * 0.39 * (-0x80 + parseInt addy.substr(2,2),16)
	oba.position.y = 0.5 * 0.39 * (-0x80 + parseInt addy.substr(22,2),16)
	oba.position.z = -20 + (2 * szmod)
	#
	# prevent pyramids leaning over the edge
	tresh = (20 - (2 * szmod)) # I am still perturbed that my instinct said this should be 50 rather than 25
	#if tna.hash is '0xf58ab705b8c1edcab36e20b04492d4ccd3a4e29a1bbe75b52bb7b79549d8e263' # our mysterious over-hanger!
	#	console.info "Mysterious Pyramid:",tresh,oba.position
	if Math.abs(oba.position.x) > tresh
		oba.position.x += Math.sign(oba.position.x) * (tresh - Math.abs oba.position.x)
		#console.info "Bringing a pyramid back from the edge!"
	if Math.abs(oba.position.y) > tresh
		oba.position.y += Math.sign(oba.position.y) * (tresh - Math.abs oba.position.y)
		#console.info "Bringing a pyramid back from the edge!!"
	#if tna.hash is '0xf58ab705b8c1edcab36e20b04492d4ccd3a4e29a1bbe75b52bb7b79549d8e263' # our mysterious over-hanger!
	#	console.info "Mysterious Pyramid ADJUSTED:",oba.position
	#
	#oba.scale = new THREE.Vector3 szmod,szmod,szmod # WHY not?
	oba.scale.x = szmod
	oba.scale.y = szmod
	oba.scale.z = szmod
	#
	#console.info "Please explain",oba.scale,code.length
	#
	stage.ggr.add oba
	#
	#oba.callback = -> navigator.clipboard.writeText addy
	oba.userData.tna = tna

queueMicrotask -> # this is the main 3d startup function and should probably be somewhere more ceremonious
	rawMaterials()
	sceneStart()
	filmReel ->
		stage.ggr.rotation.z -= stage.trn
		stage.ren.render stage.scn,stage.cam
	#console.info "Is this thing on?"
	#
	# tx https://stackoverflow.com/questions/12800150/catch-the-click-event-on-a-specific-mesh-in-the-renderer
	caster = new THREE.Raycaster
	mx = new THREE.Vector2
	stage.ren.domElement.onmousedown = (ev) ->
		rc = ev.target.getBoundingClientRect()
		mx.x = ev.x - rc.left
		mx.y = ev.y - rc.top
		mx.x /= rc.width
		mx.y /= rc.height
		mx.x *= 2
		mx.y *= 2
		mx.x -= 1
		mx.y -= 1
		mx.y = -mx.y
		console.info "That was",mx
		caster.setFromCamera mx,stage.cam
		hits = caster.intersectObjects stage.ggr.children.filter (ch) -> Boolean ch.userData.tna
		if hits[0]
			#console.log "Look at you!",hits[0]
			navigator.clipboard.writeText hits[0].object.userData.tna.hash
			#stage.ggr.remove hits[0].object

#root.style.whiteSpace = 'pre-wrap'

nmipls = (hxs) ->
	throw new SyntaxError if not hxs.match /^0x/
	throw new SyntaxError "That's odd." if hxs.length % 1
	nmi = hxs.substr 2
	sii = 0
	ssx = []
	while sii < nmi.length
		ssx.push parseInt(nmi.substr(sii,2),16)
		sii += 2
	return ssx
ascpls = (hxs) -> nmipls(hxs).filter(Boolean).map((hx) -> String.fromCharCode(hx)).join('') # strips nulls; I just wanna see what's in there.
utfpls = (hxs) -> (new TextDecoder).decode new Uint8Array nmipls(hxs).map((hx) -> parseInt(hx,16))

xl = (...ssa) ->
	return # remove this line if you want a debug-ish overlay.
	#
	for so from ssa
		if typeof so is 'string'
			lxo.insertAdjacentHTML 'beforeEnd',"#{SDX.OK.html so}\n"
		else
			lxo.insertAdjacentHTML 'beforeEnd',"#{SDX.OK.html JSON.stringify so,null,'  '}\n"
	root.appendChild document.createElement 'br'

# some translation layer and error handling for me
e3timer = 4000
e3attempts = 5
eth3 = (fnm,...ar,cbf) ->
	throw new TypeError "E1." if typeof fnm isnt 'string'
	throw new TypeError "E2." if typeof cbf isnt 'function'
	throw new Error "RE1: #{fnm}" if typeof web3.eth[fnm] isnt 'function'
	#
	ct = [fnm,...ar].join '\t' # cache token
	if hit = SMUC[ct]
		console.info "SMUC hit!",ct if not cache_only # this is only remarkable if the cache isn't expetced.
		#cbf hit
		queueMicrotask -> cbf hit
		return
	throw new Error "Near Miss: #{ ct }" if cache_only
	#console.error "Near Miss: #{ ct }" if cache_only
	#
	#`let runway`
	runway = e3attempts
	attempt = ->
		web3.eth[fnm] ...ar,(err,ans) ->
			if err
				runway -= 1
				console.error "eth3 #{fnm} call failed:",err
				throw new Error err if runway is 0 # alternative: call cbf null,err
				setTimeout attempt,e3timer
				return
			if ans is null # this is frequent and mildly annoying.
				runway -= 1
				console.error "eth3 #{fnm} call bailed:",err
				throw new Error "Server is not co-operating" if runway is 0
				setTimeout attempt,e3timer
				return
			SMUC[ct] = ans # super-mega-ultra-cache for later console-access, ifyoulike
			cbf ans,err
	attempt()

# thx https://ethereumdev.io/listening-to-new-transactions-happening-on-the-blockchain/
#web3 = new Web3 'https://cloudflare-eth.com'
web3 = new Web3 'https://eth-mainnet.alchemyapi.io/v2/s7cqlJRfstMhyAfx79ES8YLbNDUBty4s' # yeah you can flood my account if you want; it's just for the demo. <3
window.web3 = web3
token_smash = web3.utils.keccak256 "Transfer(address,address,uint256)"
#
blockPlease = (ff) ->
	if typeof bloverride is 'number'
		ff bloverride
	else
		eth3 'getBlockNumber',ff
ended = ->
	#console.info "All done! \\o/"
#
blockPlease (ans) ->
	#return xl "X1.",err if err
	xl ans
	document.querySelector('[pr=bl]').textContent = ans # may not have been known at html-time
	#console.info "TO BE CLEAR this is block",ans
	#
	eth3 'getBlock',ans,(ans) ->
		#return xl "X2.",err if err
		xl ans
		addBaseline ans
		#return
		#
		trtotal = ans.transactions.length
		trworkset = ans.transactions.slice 0 #512 # testing a theory
		tnxt = ->
			return if not pulse.alive
			return ended() if not trworkset.length
			#
			setTimeout tnxt,50 # spread it out a tiny bit
			#
			tn = trworkset.shift()
			xl '___________________________________'
			xl tn
			#
			eth3 'getTransaction',tn,(tna) ->
				return if not pulse.alive
				xl tna
				if tna.input == '0x' # assume blank input means this isn't being sent to a contract
					addDiamond trtotal,tna,tna.from # WRONG: this might be a contract
					addDiamond trtotal,tna,tna.to
					tnxt()
					return
				#else
				if tna.hash is '0x4b11e4f0838e0f67fb4f3bf44df581138ed2d1f30464f50acc9e02bb516a9269'
					console.info "You wanted to know:",tna.to
				if not tna.to
					# sorry; not depicting burns. assuming that's what these nulls are.
					tnxt()
					return
				do (tna) ->
					eth3 'getCode',tna.to,(bca) -> # bca / bytecode actual
						return if not pulse.alive
						#
						xl ascpls tna.input
						xl bca
						xl ''
						#xl "ASCII:"
						#xl ascpls bca
						eth3 'getTransactionReceipt',tna.hash,(rca) ->
							xl "My receipt for your receipt:"
							xl rca
							# HOPEFULLY this person is right <3
							# https://ethereum.stackexchange.com/questions/80285/difference-between-erc-20-and-erc-721-transaction-receipt
							# Upon experimentation: topics.length seems to hold up as solid.
							tstate = 0 # 1 for token, 2 for nft
							#
							# This loop will only break on '4' because if a transaction did both regular and NFT tokens
							# (seems UNLIKELY but seems perfectly possible) then I want to primarily reflect the NFT.
							for ev from rca.logs
								if ev.topics[0] == token_smash
									if ev.topics.length is 4
										tstate = 2
										break
									if ev.topics.length is 3
										tstate = 1
								#else
								#	console.info "It's NOT tokenny.",tna.hash,ev.topics[0],ev.topics.length
							#
							addDiamond trtotal,tna,tna.from,tstate # ALSO wrong: THIS might be a contract
							addPyramid trtotal,tna,tna.to,bca,tstate # this call is getting out of hand, but tidyness isn't my priority rn.
							tnxt()
							return
						return
				return
			return # all the way home.
		tnxt()
		return
	
#web3.eth.getBlock blk,(err,ans) ->

###
# this doesn't work :|
room.lld ->
	web3.eth.subscribe 'newBlockHeaders',(err,ans) ->
		return xl err if err
		xl ans
	return ->
		web3.eth.clearSubscriptions()
###