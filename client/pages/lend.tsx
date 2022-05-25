import React from 'react'
import Header from '../components/Header'

const style = {
  wrapper: `h-screen max-h-screen h-min-screen bg-[#1A1A1D] text-black select-none flex flex-col`,
}

const Lend = () => {
  return (
    <div className={`${style.wrapper}`}>
      <Header />
      <div>this is lend page</div>
      <video src="https://ipfs.moralis.io:2053/ipfs/QmaD8X74xPhJy75X1uwCLWdd4Grs3yE29uyvWcaF3FiP2L/nft.mp4"/>
    </div>
  )
}

export default Lend
