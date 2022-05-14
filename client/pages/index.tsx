import type { NextPage } from 'next'
import Header from './../components/Header'

const style = {
  wrapper: `h-screen max-h-screen h-min-screen w-screen bg-[#1A1A1D] text-black select-none flex flex-col`,
}

const Home: NextPage = () => {
  return (
    <div className={style.wrapper}>
      <Header />
    </div>
  )
}

export default Home
