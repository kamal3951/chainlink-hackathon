import React, { useState, useEffect, useContext } from 'react'
import Image from 'next/image'
import Link from 'next/link'
import { useMoralis, useWeb3ExecuteFunction } from 'react-moralis'
import { TransactionContext } from '../context/TransactionContext'

const style = {
  wrapper: `w-3/4 flex justify-center items-start`,
  headerLogo: `flex w-1/4 items-center justify-start`,
  nav: `flex-1 mr-40 flex justify-center items-center`,
  navItemsContainer: `flex bg-[#CECECE] rounded-3xl`,
  navItem: `px-4 py-2 m-1 flex items-center text-lg font-semibold text-[0.9rem] cursor-pointer rounded-3xl`,
  activeNavItem: `bg-[#1A1A1D] text-white border`,
  buttonsContainer: `flex w-1/4.1 justify-between items-center`,
  button: `flex items-center bg-[#CECECE] rounded-2xl mx-2 text-[0.9rem] font-semibold cursor-pointer border`,
  buttonPadding: `p-2`,
  buttonTextContainer: `h-8 flex items-center`,
  buttonIconContainer: `flex items-center justify-center w-8 h-8`,
  buttonAccent: `bg-[#CECECE] hover:border-[#FFFFFF] hover:bg-[#1A1A1D] hover:text-white h-full rounded-2xl flex items-center justify-center text-black`,
  accountNumber: `hover:bg-[#1A1A1D] hover:text-white border hover:border-[#FFFFFF]`,
  newbutton: `flex flex-row w-40 justify-center items-center bg-[#CECECE] rounded-xl mx-2 text-[0.9rem] font-semibold cursor-pointer border mb-0.5`,
  newbuttonPadding: `p-2`,
  newbuttonTextContainer: `flex items-center`,
  dropDownItemAccount: `flex break-all flex-row w-40 h-16 justify-center items-center bg-[#CECECE] rounded-lg mx-2 text-[0.9rem] font-semibold cursor-pointer border mb-0.5 p-2`,
  dropDownItemBalance: `flex break-all flex-row w-40 h-8 justify-center items-center bg-[#CECECE] rounded-lg mx-2 text-[0.9rem] font-semibold cursor-pointer border mb-0.5 p-2`,
  repayLoan: `w-28 flex items-center justify-center`,
}

const Header = () => {
  const [selectedNav, setSelectedNav] = useState('home')
  const [isActive, setIsActive] = useState(false)
  const { isAuthenticated, user, Moralis } = useMoralis()
  const { logIn, logOut } = useContext(TransactionContext)

  useEffect(() => {
    const newSelected = JSON.parse(localStorage.getItem('user') || '{}')
    setSelectedNav(newSelected)
  })
  const contractProcessor = useWeb3ExecuteFunction()

  const HandleClick = async (borrower: string) => {
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

  }

  return (
    <div
      style={{
        display: 'flex',
        paddingTop: 16,
        alignItems: 'flex-start',
        justifyContent: 'space-around',
        height: 140,
      }}
    >
      <div className={style.wrapper}>
        <div className={style.headerLogo}>
          <Image src="/uniswap.png" alt="uniswap" height={40} width={40} />
        </div>
        <div className={style.nav}>
          <div className={style.navItemsContainer}>
            <Link href="/">
              <div
                onClick={() =>
                  localStorage.setItem('user', JSON.stringify('home'))
                }
                className={`${style.navItem} ${
                  selectedNav === 'home' && style.activeNavItem
                }`}
              >
                Home
              </div>
            </Link>
            <Link href="/lend">
              <div
                onClick={() =>
                  localStorage.setItem('user', JSON.stringify('lend'))
                }
                className={`${style.navItem} ${
                  selectedNav === 'lend' && style.activeNavItem
                }`}
              >
                Lend
              </div>
            </Link>
            <Link href="/borrow">
              <div
                onClick={() =>
                  localStorage.setItem('user', JSON.stringify('borrow'))
                }
                className={`${style.navItem} ${
                  selectedNav === 'borrow' && style.activeNavItem
                }`}
              >
                Borrow
              </div>
            </Link>
          </div>
        </div>
        <div className={style.buttonsContainer}></div>
      </div>
      <div
        className={`${style.newbutton} ${style.newbuttonPadding} ${style.accountNumber}`}
      >
        <div className={style.repayLoan} onClick={HandleClick}>
          <span>Repay Loan</span>
        </div>
      </div>
      {isAuthenticated ? (
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center',
          }}
          onMouseEnter={() => setIsActive(true)}
          onMouseLeave={() => setIsActive(false)}
        >
          <div
            className={`${style.newbutton} ${style.newbuttonPadding} ${style.accountNumber}`}
          >
            <div className={style.newbuttonTextContainer}>
              <span>It's ME</span>
            </div>
          </div>
          {isActive ? (
            <div>
              <div
                className={`${style.accountNumber} ${style.dropDownItemAccount}`}
              >
                <div className={style.newbuttonTextContainer}>
                  {user?.get('ethAddress')}
                </div>
              </div>
              <div
                className={`${style.accountNumber} ${style.dropDownItemBalance}`}
              >
                <div className={style.newbuttonTextContainer} onClick={logOut}>
                  Log Out
                </div>
              </div>
            </div>
          ) : null}
        </div>
      ) : (
        <div
          onClick={() => {
            logIn()
          }}
          className={`${style.button} w-40 ${style.buttonPadding}`}
        >
          <div className={`${style.buttonAccent} ${style.buttonPadding}`}>
            Connect Wallet
          </div>
        </div>
      )}
    </div>
  )
}

export default Header
