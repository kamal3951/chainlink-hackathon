import React, { useState, useContext, useEffect } from 'react'
import Image from 'next/image'
import { AiOutlineDown } from 'react-icons/ai'
import { TransactionContext } from '../context/TransactionContext'

const style = {
  wrapper: `w-screen flex justify-center items-start`,
  headerLogo: `flex w-1/4 items-center justify-start`,
  nav: `flex-1 flex justify-center items-center`,
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
  newbutton: `flex flex-row w-36 justify-center items-center bg-[#CECECE] rounded-xl mx-2 text-[0.9rem] font-semibold cursor-pointer border mb-0.5`,
  newbuttonPadding: `p-2`,
  newbuttonTextContainer: `h-8 flex items-center`,
  dropDownItemAccount: `flex break-all flex-row w-36 h-28 justify-center items-center bg-[#CECECE] rounded-lg mx-2 text-[0.9rem] font-semibold cursor-pointer border mb-0.5 p-2`,
  dropDownItemBalance: `flex break-all flex-row w-36 h-16 justify-center items-center bg-[#CECECE] rounded-lg mx-2 text-[0.9rem] font-semibold cursor-pointer border mb-0.5 p-2`,
}

const Header = () => {
  const [selectedNav, setSelectedNav] = useState('home')
  const { connectWallet, currentAccount, userBalance, getUserBalance } = useContext(TransactionContext)
  const [isActive, setIsActive] = useState(false)
  console.log(userBalance)

  return (
    <div
      style={{
        display: 'flex',
        paddingTop: 16,
        alignItems: 'flex-start',
        justifyContent: 'space-around',
      }}
    >
      <div className={style.wrapper}>
        <div className={style.headerLogo}>
          <Image src="/uniswap.png" alt="uniswap" height={40} width={40} />
        </div>
        <div className={style.nav}>
          <div className={style.navItemsContainer}>
            <div
              onClick={() => setSelectedNav('home')}
              className={`${style.navItem} ${
                selectedNav === 'home' && style.activeNavItem
              }`}
            >
              Home
            </div>
            <div
              onClick={() => setSelectedNav('lend')}
              className={`${style.navItem} ${
                selectedNav === 'lend' && style.activeNavItem
              }`}
            >
              Lend
            </div>
            <div
              onClick={() => setSelectedNav('borrow')}
              className={`${style.navItem} ${
                selectedNav === 'borrow' && style.activeNavItem
              }`}
            >
              Borrow
            </div>
          </div>
        </div>
        <div className={style.buttonsContainer}>
          <div className={`${style.button} ${style.buttonPadding}`}>
            <div className={style.buttonIconContainer}>
              <Image src="/eth.png" alt="eth logo" height={20} width={20} />
            </div>
            <p>Ethereum</p>
            <div className={style.buttonIconContainer}>
              <AiOutlineDown />
            </div>
          </div>
        </div>
      </div>
      {currentAccount ? (
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
              <div className={`${style.accountNumber} ${style.dropDownItemAccount}`}>
                <div className={style.newbuttonTextContainer}>
                  {currentAccount}
                </div>
              </div>
              <div className={`${style.accountNumber} ${style.dropDownItemBalance}`}>
                <div className={style.newbuttonTextContainer}>
                  {userBalance}
                </div>
              </div>
            </div>
          ) : null}
        </div>
      ) : (
        <div
          onClick={() => {getUserBalance();connectWallet(); }}
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
