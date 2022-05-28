import type { NextPage } from 'next'
import Header from './../components/Header'

const style = {
  wrapper: `h-screen max-h-screen h-min-screen w-screen bg-[#1A1A1D] text-black select-none flex flex-col`,
  uniloan: `text-white text-6xl text-mono ml-[32.5%]`,
  howWorks: `text-white text-mono text-2xl ml-[7%]`,
  instructions: ``,
}

const Home: NextPage = () => {
  return (
    <div className={style.wrapper}>
      <Header />
      <div className={style.uniloan}>UNILOAN</div>
      <div>
        <div className={style.howWorks}>How It Works ?</div>
        <div className={style.instructions}>

        </div>
      </div>
    </div>
  )
}

export default Home
