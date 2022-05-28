import React, { useState } from 'react'
import { useMoralis } from 'react-moralis'

export const TransactionContext = React.createContext()

export const TransactionProvider = ({ children }) => {
  const contractAddress = '0x3E2DE52E5A1bc16AAf58F5AB6D50A7CCf2D90820'
  const [currentUser, setCurrentUser] = useState()
  const { authenticate, isAuthenticated, user, logout } = useMoralis()
  const logIn = async () => {
    try {
      if (!isAuthenticated) {
        await authenticate()
        let newUser = user.get('ethAddress')
        setCurrentUser(newUser)
      }
    } catch (error) {
      console.log(error)
    }
  }

  const logOut = async () => {
    try {
      if (isAuthenticated) {
        await logout()
      }
    } catch (error) {
      console.log(error)
    }
  }

  return (
    <TransactionContext.Provider value={{ logIn, currentUser, logOut, contractAddress }}>
      {children}
    </TransactionContext.Provider>
  )
}
