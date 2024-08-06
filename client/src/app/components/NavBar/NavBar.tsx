"use client";

import Link from "next/link";
import { useState } from "react";
import ConnectWallet from "./ConnectWallet/ConnectWallet";
import useSigner from "@/state/signer";

export const NavBar = () => {
  const signerInfo = useSigner();

  return (
    <nav className="bg-white-800 text-black p-4 sm:p-6 md:flex md:justify-between md:items-center">
      <div className="container mx-auto flex justify-between items-center">
        <a href="/" className="text-2xl font-bold">
          PayChain
        </a>

        <div className="hidden md:flex">
          <Link href="/register" className="mx-2 hover:text-gray-300">
            Register
          </Link>
          <Link href="/send" className="mx-2 hover:text-gray-300">
            Send
          </Link>
          <Link href="/request" className="mx-2 hover:text-gray-300">
            Request
          </Link>
          <Link href="/deposit" className="mx-2 hover:text-gray-300">
            Deposit
          </Link>
          <Link href="/withdraw" className="mx-2 hover:text-gray-300">
            Withdraw
          </Link>
        </div>

        <div>
          {signerInfo.connected ? (
            <p>{signerInfo.address}</p>
          ) : (
            <ConnectWallet />
          )}
        </div>
      </div>
    </nav>
  );
};
