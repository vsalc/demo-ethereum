"use client";

import Link from "next/link";
import { useState } from "react";
import useSigner from "@/state/signer";

const ConnectWallet = () => {
  const signerInfo = useSigner();

  return (
    <div>
      <button onClick={signerInfo.connectWallet} disabled={signerInfo.loading}>
        {signerInfo.loading ? "busy..." : "Connect Wallet"}
      </button>
    </div>
  );
};

export default ConnectWallet;
