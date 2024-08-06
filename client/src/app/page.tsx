"use client";

import Image from "next/image";
import paychain from "@/state/paychain";
import { useState } from "react";

export default function Home() {
  const [user, setUser] = useState("Am I registered?");

  const handleClick = async () => {
    const isUser = await paychain.methods.getRegistered().call();
    if (isUser) {
      setUser("Yes, proceed.");
    } else {
      setUser("Nope! Please register to use this app.");
    }
  };

  return (
    <div className="center-screen">
      <button onClick={handleClick}>{user}</button>
    </div>
  );
}
