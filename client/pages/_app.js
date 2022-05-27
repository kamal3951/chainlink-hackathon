import '../styles/globals.css'
import { TransactionProvider } from '../context/TransactionContext'
import { MoralisProvider } from 'react-moralis'

function MyApp({ Component, pageProps }) {
  return (
    <MoralisProvider
      appId="z52FQV47PhI0MC1pudMkL00JLcpj9ZnFd4ij0Vbo"
      serverUrl="https://peebfq2qsx6g.usemoralis.com:2053/server"
    >
      <TransactionProvider>
        <Component {...pageProps} />
      </TransactionProvider>
    </MoralisProvider>
  )
}

export default MyApp

