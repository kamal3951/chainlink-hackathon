import React, { useState, useEffect } from 'react'
import { ethers } from 'ethers'

export const TransactionContext = React.createContext()

let eth

if (typeof window !== 'undefined') eth = window.ethereum

export const TransactionProvider = ({ children }) => {
  const [currentAccount, setCurrentAccount] = useState()
  const [userBalance, setUserBalance] = useState(0)

  useEffect(() => {
    checkIfWalletIsConnected()
  }, [])

  const connectWallet = async (metamask = eth) => {
    try {
      if (!metamask) return alert('Please Install Metamask')
      const accounts = await metamask.request({ method: 'eth_requestAccounts' })
      setCurrentAccount(accounts[0])
    } catch (err) {
      console.error(err)
      throw new Error('No Ethereum Object')
    }
  }

  const checkIfWalletIsConnected = async (metamask = eth) => {
    try {
      if (!metamask) return alert('Please install metamask')
      const accounts = await metamask.request({ method: 'eth_accounts' })
      if (accounts.length) setCurrentAccount(accounts[0])
    } catch (error) {
      console.error(error)
      throw new Error('No ethereum object.')
    }
  }

  const getUserBalance = (accountAddress) => {
    window.ethereum
      .request({ method: 'eth_getBalance', params: [accountAddress, 'latest'] })
      .then((balance) => {
        setUserBalance(ethers.utils.formatEther(balance))
      })
      .catch((error) => {
        setErrorMessage(error.message)
      })
  }

  return (
    <TransactionContext.Provider
      value={{
        currentAccount,
        connectWallet,
        userBalance,
        getUserBalance,
      }}
    >
      {children}
    </TransactionContext.Provider>
  )
}
