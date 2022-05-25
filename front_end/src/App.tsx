import React from 'react';
import {DAppProvider, ChainId } from "@usedapp/core"
import { Header } from "./components/Header"

function App() {
  return (
    <DAppProvider config={{
      supportedChains: [ChainId.Kovan, ChainId.Rinkeby, 1337]
    }}>
      <Header />
      <div>Hi!</div>
    </DAppProvider>
  )
}

export default App;
