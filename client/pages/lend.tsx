import React, { useEffect, useState, useContext } from 'react'
import Header from '../components/Header'
import {
  useMoralis,
  useMoralisSolanaCall,
  useMoralisWeb3Api,
  useWeb3ExecuteFunction,
} from 'react-moralis'
import Modal from 'react-modal'
import { TransactionContext } from '../context/TransactionContext'

const style = {
  wrapper: `bg-[#1A1A1D] h-auto min-h-screen text-black select-none flex flex-col`,
  nftContainer: `ml-8 mr-12 mt-4 flex justify-start flex-wrap`,
  nftName: `text-white font-mono text-lg`,
  nftImageContainer: `text-white font-mono w-64 h-64 mt-4`,
  nftImage: `w-64 h-64`,
  liftNft: `text-black font-mono cursor-pointer text-lg rounded-sm bg-[#33b249] w-16 flex justify-center items-center hover:bg-[#5adbb5]`,
  nftCardContainer: `flex flex-col items-center justify-around mx-5 mb-5 mt-7 border bg-[#0f0e0e] rounded-md w-72 h-96 hover:shadow-2xl hover:border-stone-400`,
  crossButton: `cursor-pointer text-white absolute right-6`,
  timeInputLabel: `text-white text-xl p-4 mt-4 font-mono h-20`,
  submitButton: `text-white text-xl font-mono mt-12 w-28 h-12 border rounded-md hover:bg-[white] hover:text-black`,
  tokenId: `text-white text-mono text-2xl break-all`,
}

function fixUrl(url: string) {
  if (url?.startsWith('ipfs')) {
    return (
      'https://ipfs.moralis.io:2053/ipfs/' + url?.split('ipfs://')?.slice(-1)
    )
  } else {
    return url
  }
}

const NFTCard = ({ nft, label }) => {
  const { user, Moralis } = useMoralis()
  const lender = user?.get('ethAddress')
  const [isopen, setIsopen] = useState(false)
  const nftData = JSON?.parse(nft?.metadata)
  console.log(nftData)
  console.log(fixUrl(nftData?.image))
  const contractProcessor = useWeb3ExecuteFunction()

  async function lendMoney(tokenId: number) {
    let options = {
      contractAddress: '0x3E2DE52E5A1bc16AAf58F5AB6D50A7CCf2D90820',
      functionName: 'lendMoney',
      abi: [
        {
          inputs: [
            { internalType: 'uint256', name: 'tokenId', type: 'uint256' },
            { internalType: 'address', name: 'lender', type: 'address' },
          ],
          name: 'lendMoney',
          outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
          stateMutability: 'payable',
          type: 'function',
        },
      ],
      params: {
        tokenId: { tokenId },
        lender: { lender },
      },
      msgValue: Moralis.Units.ETH(0.1)
    }
    await contractProcessor.fetch({
      params: options,
    })
  }

  return (
    <>
      <div className={style.nftCardContainer}>
        <div className={style.nftImageContainer}>
          <img
            className={style.nftImage}
            src={fixUrl(nftData?.image?.trim())}
            alt="cannot display image"
          />
        </div>
        <div className={style.nftName}>
          {`${nftData?.name?.toUpperCase()} - ${nft?.token_id}`}
        </div>
        <div
          className={style.liftNft}
          onClick={() => {
            setIsopen(true)
            console.log(nft?.token_id)
          }}
        >
          {label}
        </div>
      </div>
      <Modal
        isOpen={isopen}
        onRequestClose={() => {
          setIsopen(false)
        }}
        style={{
          overlay: {
            background: 'rgba(49,49,49,0.8)',
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
          },
          content: {
            position: 'absolute',
            left: '33%',
            top: '25%',
            background: '#0f0e0e',
            width: 450,
            height: 350,
            borderRadius: 8,
            display: 'flex',
            alignItems: 'center',
            flexDirection: 'column',
            padding: '10px',
          },
        }}
      >
        <div onClick={() => setIsopen(false)} className={style.crossButton}>
          X
        </div>
        <div className={style.timeInputLabel}>
          Lend 50% of Liquidity for NFT with
        </div>
        <div className={style.tokenId}>Token ID - {nft?.token_id}</div>
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginTop: '60px',
            height: '150px',
          }}
        >
          <button
            className={style.submitButton}
            type="submit"
            onClick={() => lendMoney(nft?.token_id)}
          >
            Proceed
          </button>
        </div>
      </Modal>
    </>
  )
}

const Lend = () => {
  const { contractAddress } = useContext(TransactionContext)
  const { isInitialized, isWeb3Enabled, enableWeb3 } = useMoralis()
  const Web3Api = useMoralisWeb3Api()
  const [userEthNFTs, setUserEthNFTs] = useState()
  useEffect(() => {
    if (!isWeb3Enabled) enableWeb3()
    if (isInitialized) {
      const options = {
        chain: 'rinkeby',
        address: `${contractAddress}`,
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
          return <NFTCard nft={nft} label="LEND" key={index} />
        })}
      </div>
    </div>
  )
}

export default Lend
