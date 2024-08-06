"use client";

import Image from "next/image";
import instance from "@/state/paychain";
import { useState } from "react";
import { getStaticProps } from "next/dist/build/templates/pages";
import useSigner from "@/state/signer";

export default function Home() {
  const signerInfo = useSigner();
  const [user, setUser] = useState("Am I registered?");

  async function handleClick() {
    // error right here
    // const test = await instance.methods.manager();
  }

  return (
    <div className="center-screen">
      <button onClick={handleClick}>{user}</button>
    </div>
  );
}
