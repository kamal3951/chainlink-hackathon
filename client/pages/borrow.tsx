import React, { useEffect, useState } from 'react'
import Header from '../components/Header'
import { useMoralis, useMoralisWeb3Api } from 'react-moralis'

const style = {
  wrapper: `bg-[#1A1A1D] h-auto min-h-screen text-black select-none flex flex-col`,
  nftContainer: `ml-8 mr-12 mt-4 flex justify-start flex-wrap`,
  nftName: `text-white font-mono text-lg`,
  nftImageContainer: `text-white font-mono w-64 h-64 mt-4`,
  nftImage: `w-64 h-64`,
  liftNft: `text-black font-mono cursor-pointer text-lg rounded-sm bg-[#33b249] w-16 flex justify-center items-center hover:bg-[#5adbb5]`,
  nftCardContainer: `flex flex-col items-center justify-around mx-5 mb-5 mt-7 border bg-[#0f0e0e] rounded-md w-72 h-96 hover:shadow-2xl hover:border-stone-400`,
}

function fixUrl(url: string){
  if(url?.startsWith("ipfs")){
    return "https://ipfs.moralis.io:2053/ipfs/"+url?.split("ipfs://ipfs/")?.slice(-1)
  } else {
    return url+"?format=json"
  }
}



const NFTCard = ({ nft }) => {
  const nftData = JSON.parse(nft?.metadata)
  console.log(nftData)

  return (
    <div className={style.nftCardContainer}>
      <div className={style.nftImageContainer}>
        <img
          className={style.nftImage}
          src={fixUrl(nftData?.image)}
          alt="cannot display image"
        />
      </div>
      <div className={style.nftName}>{nftData?.name?.toUpperCase()}</div>
      <div className={style.liftNft}>LEND</div>
    </div>
  )
}

const Borrow = () => {
  const { isInitialized } = useMoralis()
  const Web3Api = useMoralisWeb3Api()
  const [userEthNFTs, setUserEthNFTs] = useState()
  useEffect(() => {
    if (isInitialized) {
      const options = {
        chain: 'eth',
        address: '0xec3CdB6750d28abA0A7A044aa47e5A6Bd7A88A75',
        //   address: `${_currentUser}`,
      }
      Web3Api.account.getNFTs(options).then((res) => {
        setUserEthNFTs(res?.result)
      })
    }
  }, [isInitialized])

  console.log(userEthNFTs)

  return (
    <div className={style.wrapper}>
      <Header />
      <div className={style.nftContainer}>
        {userEthNFTs?.map((nft: any, index: number) => {
          return <NFTCard nft={nft} key={index} />
        })}
      </div>
    </div>
  )
}

export default Borrow
