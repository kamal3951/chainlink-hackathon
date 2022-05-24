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
    </div>
  )
}

export default Lend
