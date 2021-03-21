import React, { useEffect,useLayoutEffect,useRef } from "react";
import * as THREE from "three";
import SMUC from "./SMUC";
import Web3 from "web3";
import etherPalace from "./palace";
import { Shaders, Node, GLSL } from "gl-react";
import MersenneTwister from "mersenne-twister";

/*
Create your Custom style to be turned into a EthBlock.art Mother NFT

Basic rules:
 - use a minimum of 1 and a maximum of 4 "modifiers", modifiers are values between 0 and 1,
 - use a minimum of 1 and a maximum of 3 colors, the color "background" will be set at the canvas root
 - Use the block as source of entropy, no Math.random() allowed!
 - You can use a "shuffle bag" using data from the block as seed, a MersenneTwister library is provided

 Arguments:
  - block: the blockData, in this example template you are given 3 different blocks to experiment with variations, check App.js to learn more
  - mod[1-3]: template modifier arguments with arbitrary defaults to get your started
  - color: template color argument with arbitrary default to get you started

Getting started:
 - Write gl-react code, comsuming the block data and modifier arguments,
   make it cool and use no random() internally, component must be pure, output deterministic
 - Customize the list of arguments as you wish, given the rules listed below
 - Provide a set of initial /default values for the implemented arguments, your preset.
 - Think about easter eggs / rare attributes, display something different every 100 blocks? display something unique with 1% chance?

 - check out https://gl-react-cookbook.surge.sh/ for examples!
*/

export const styleMetadata = {
  name: "",
  description: "",
  image: "",
  creator_name: "",
  options: {
    mod1: 0.5,
    mod2: 0.5,
  },
};

const CustomStyle = ({ block, attributesRef, width, height, mod1, mod2 }) => {
  useAttributes(attributesRef);

  const { hash } = block;

  const rng = new MersenneTwister(parseInt(hash.slice(0, 16), 16));

  ////
  let gtesttt = new THREE.BoxGeometry(1,1,1)
  let mtesttt = new THREE.MeshPhongMaterial('0x6622FF',{emissive:'#FFFFFF'})
  let mstesttt = new THREE.Mesh(gtesttt,mtesttt)
  //
  let stage = {}
  function sizeAndRezize () {
    let ww = width
    let hh = height
    stage.ren.setPixelRatio(devicePixelRatio)
    stage.ren.setSize(ww,hh)
    stage.cam = new THREE.PerspectiveCamera(35,ww/hh,0.1,2000)
    stage.cam.position.set(0,-200,5)
    stage.cam.rotation.x = (Math.PI/2) * 0.97
  }
  //
  stage.ren = new THREE.WebGLRenderer
  sizeAndRezize()
  stage.scn = new THREE.Scene
  stage.ggr = new THREE.Group
  //
  stage.scn.add(new THREE.AmbientLight(0x6622FF))
  //
  let light = new THREE.DirectionalLight(0x5566DD, 0.7)
  light.position.set(-100,0,50)
  stage.scn.add(light)
  //
  light = new THREE.DirectionalLight(0x000099, 1.0)
  light.position.set(0,0,50)
  stage.ggr.add(light) // add it to the spinning group
  //
  light = new THREE.DirectionalLight(0x332255, 1.0)
  light.position.set(0,0,-50)
  stage.ggr.add(light) // add it to the spinning group
  //
  stage.scn.add(stage.ggr)

  stage.ggr.add(mstesttt)
  //
  //stage.ren.domElement.style.width = '100%'
  //stage.ren.domElement.style.height = '100%'

  stage.ren.render(stage.scn,stage.cam)
  
  // My react is rusty..
  let frag_ref = useRef()
  let pulse = {alive:true}
  useLayoutEffect(() => {
    console.info("Where is it?",block)
    stage = etherPalace(pulse,10892674,frag_ref.current,{width,height,THREE,SMUC,Web3,mod1,mod2})
    //frag_ref.current.appendChild(stage.ren.domElement)
    return () => {
      pulse.alive = false;
      if (stage.ren) stage.ren.domElement.remove()
    }
  //},[width,height])
  })
  ////

  return <div ref={frag_ref} />
};

function useAttributes(ref) {
  // Update custom attributes related to style when the modifiers change
  useEffect(() => {
    ref.current = () => {
      return {
        // This is called when the final image is generated, when creator opens the Mint NFT modal.
        // should return an object structured following opensea/enjin metadata spec for attributes/properties
        // https://docs.opensea.io/docs/metadata-standards
        // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1155.md#erc-1155-metadata-uri-json-schema

        attributes: [
          {
            trait_type: "your trait here text",
            value: "replace me",
          },
        ],
      };
    };
  }, [ref]);
}

export default CustomStyle;
