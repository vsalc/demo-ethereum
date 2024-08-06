"use client";

import { createContext, ReactNode, use, useContext, useState } from "react";
import { JsonRpcSigner, ethers } from "ethers";

type SignerContextType = {
  signer?: JsonRpcSigner;
  address?: string;
  loading: boolean;
  connected: boolean;
  connectWallet: () => Promise<void>;
};

const SignerContext = createContext<SignerContextType>({} as any);

const useSigner = () => useContext(SignerContext);

export const SignerProvider = ({ children }: { children: ReactNode }) => {
  const [signer, setSigner] = useState<JsonRpcSigner>();
  const [address, setAddress] = useState<string>();
  const [connected, setConnected] = useState(false);
  const [loading, setLoading] = useState(false);

  const connectWallet = async () => {
    setLoading(true);
    let provider;
    let signer;
    let address;

    try {
      if (
        typeof window !== "undefined" &&
        typeof window.ethereum !== "undefined"
      ) {
        // we are in the browser and metamask is running
        window.ethereum.request({ method: "eth_requestAccounts" });
        provider = new ethers.BrowserProvider(window.ethereum);
        signer = await provider.getSigner();
        address = await signer.getAddress();
        setAddress(address);
        setSigner(signer);
        setConnected(true);
      } else {
        // we are on the server *OR* the user is not running metamask
        provider = new ethers.JsonRpcProvider(
          "https://sepolia.infura.io/v3/ec365b16fc5046828290eebda11ace42"
        );
      }
    } catch (e) {
      console.log(e);
    }
    setLoading(false);
  };

  const contextValue = { signer, address, loading, connected, connectWallet };

  return (
    <SignerContext.Provider value={contextValue}>
      {children}
    </SignerContext.Provider>
  );
};

export default useSigner;
