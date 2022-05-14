import React, { useState, useEffect } from 'react'
import { ethers } from 'ethers'

export const TransactionContext = React.createContext()

let eth

if (typeof window !== 'undefined') eth = window.ethereum

export const TransactionProvider = ({ children }) => {
  const [currentAccount, setCurrentAccount] = useState()
  const [userBalance, setUserBalance] = useState()

  useEffect(() => {
    checkIfWalletIsConnected()
  }, [])

  const connectWallet = async (metamask = eth) => {
    try {
      if (metamask) {
        const accounts = await metamask.request({
          method: 'eth_requestAccounts',
        })
        setCurrentAccount(accounts[0])
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const signer = provider.getSigner()
        const balance = await signer.getBalance()
        setUserBalance(ethers.utils.formatEther(balance._hex))
      }
    } catch (err) {
      console.error(err)
      throw new Error('No Ethereum Object')
    }
  }

  const checkIfWalletIsConnected = async (metamask = eth) => {
    try {
      if (!metamask) return alert('Please install metamask')
      const accounts = await metamask.request({ method: 'eth_accounts' })
      if (accounts.length) {
        setCurrentAccount(accounts[0])
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const signer = provider.getSigner()
        const balance = await signer.getBalance()
        setUserBalance(ethers.utils.formatEther(balance._hex))
      }
    } catch (error) {
      console.error(error)
      throw new Error('No ethereum object.')
    }
  }

  return (
    <TransactionContext.Provider
      value={{
        currentAccount,
        connectWallet,
        userBalance,
      }}
    >
      {children}
    </TransactionContext.Provider>
  )
}
