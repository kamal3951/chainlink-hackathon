import React, { useEffect, useState, useContext } from 'react'
import Header from '../components/Header'
import {
  useMoralis,
  useMoralisWeb3Api,
  useWeb3ExecuteFunction,
  useWeb3Transfer,
} from 'react-moralis'
import Modal from 'react-modal'

const style = {
  wrapper: `bg-[#1A1A1D] h-auto min-h-screen text-black select-none flex flex-col`,
  nftContainer: `ml-8 mr-12 mt-4 flex justify-start flex-wrap`,
  nftName: `text-white font-mono text-lg break-all`,
  nftImageContainer: `text-white font-mono w-64 h-64 mt-4`,
  nftImage: `w-64 h-64`,
  liftNft: `text-black font-mono cursor-pointer text-lg rounded-sm bg-[#33b249] w-16 flex justify-center items-center hover:bg-[#5adbb5]`,
  nftCardContainer: `flex flex-col items-center justify-around mx-5 mb-5 mt-7 border bg-[#0f0e0e] rounded-md w-72 h-96 hover:shadow-2xl hover:border-stone-400`,
  crossButton: `cursor-pointer text-white absolute right-6`,
  timeInputLabel: `text-white text-xl p-4 mt-4 font-mono h-20`,
  submitButton: `text-white text-xl font-mono w-28 h-12 border rounded-md hover:bg-[white] hover:text-black`,
  inputBox: `bg-[#0f0e0e] border h-12 w-80 text-white text-mono text-xl pl-4`,
  tokenid: `text-white text-mono text-2xl break-all`,
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
  const [isopen, setIsopen] = useState(false)
  const { user, Moralis } = useMoralis()
  const nftData = JSON?.parse(nft?.metadata)
  console.log(nftData)
  console.log(fixUrl(nftData?.image))
  const { fetch, error, isFetching } = useWeb3Transfer({
    type: 'erc721',
    receiver: '0x3E2DE52E5A1bc16AAf58F5AB6D50A7CCf2D90820',
    contractAddress: '0xC36442b4a4522E871399CD717aBDD847Ab11FE88',
    tokenId: `${nft?.token_id}`,
  })
  const contractProcessor = useWeb3ExecuteFunction()

  const HandleClick = async (tokenID: number, borrower: string) => {
    let options = {
      contractAddress: '0x3E2DE52E5A1bc16AAf58F5AB6D50A7CCf2D90820',
      functionName: 'listNft',
      abi: [
        {
          inputs: [
            {
              internalType: 'uint256',
              name: 'tokenId',
              type: 'uint256',
            },
            {
              internalType: 'uint256',
              name: 'LoanTimePeriod',
              type: 'uint256',
            },
            {
              internalType: 'address payable',
              name: 'borrower',
              type: 'address',
            },
          ],
          name: 'listNft',
          outputs: [],
          stateMutability: 'nonpayable',
          type: 'function',
        },
      ],
      params: {
        tokenId: { tokenID },
        LoanTimePeriod: 0,
        borrower: `${borrower}`,
      },
      msgValue: Moralis.Units.ETH(0),
    }
    await contractProcessor.fetch({
      params: options,
    })
    fetch({
      onSuccess: (tx) =>
        tx.wait().then(() => {
          alert('Transaction Done')
        }),
    })
    setIsopen(false)
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
            width: 500,
            height: 400,
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
          Fill the Time Duration in Months -{' '}
        </div>
        <div className={style.tokenid}>Token ID - {nft?.token_id}</div>
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
          <input
            type="text"
            className={style.inputBox}
            placeholder="For Example - 13"
          />
          <button
            className={style.submitButton}
            type="submit"
            onClick={() => HandleClick(nft?.token_id, user?.get('ethAddress'))}
            disabled={isFetching}
          >
            {error && console.log(error)}
            Proceed
          </button>
        </div>
      </Modal>
    </>
  )
}

const Borrow = () => {
  const { isInitialized, user, isWeb3Enabled, enableWeb3 } = useMoralis()
  const Web3Api = useMoralisWeb3Api()
  const [userEthNFTs, setUserEthNFTs] = useState()
  useEffect(() => {
    if (!isWeb3Enabled) enableWeb3()

    if (isInitialized) {
      const options = {
        chain: 'rinkeby',
        // address: '0xCaE2DBf72cABfC7ee135256ff56FDc216a2a419A',
        address: `${user?.get('ethAddress')}`,
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
          return <NFTCard nft={nft} label="STAKE" key={index} />
        })}
      </div>
    </div>
  )
}

export default Borrow
