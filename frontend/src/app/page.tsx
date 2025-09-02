"use client";

import { useState } from "react";

export default function Home() {
  const [githubLink, setGithubLink] = useState("");
  const [responseMsg, setResponseMsg] = useState<string | null>(null);

  const handleSubmit = async () => {
    try {
      const response = await fetch("http://localhost:8000/walker/infer", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer YOUR_TOKEN_HERE" // replace with real token
        },
        body: JSON.stringify({
          github_link: githubLink,
          message: "Process this GitHub repo"
        }),
      });

      if (!response.ok) {
        throw new Error(await response.text());
      }

      const data = await response.json();
      setResponseMsg(data.reports?.[0]?.response || "No response received");
    } catch (err: any) {
      setResponseMsg("Error: " + err.message);
    }
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gray-50 p-6">
      <h1 className="text-4xl font-bold mb-2">Codebase Genius</h1>
      <p className="text-lg text-gray-600 mb-6">
        Paste your GitHub repo link below
      </p>

      {/* GitHub link input */}
      <div className="flex flex-col sm:flex-row gap-3 w-full max-w-md">
        <input
          type="text"
          placeholder="https://github.com/user/repo"
          value={githubLink}
          onChange={(e) => setGithubLink(e.target.value)}
          className="flex-1 border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <button
          onClick={handleSubmit}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg shadow hover:bg-blue-700 transition"
        >
          Submit
        </button>
      </div>

      {/* Response display */}
      {responseMsg && (
        <div className="mt-6 p-4 bg-white border rounded-lg shadow w-full max-w-md">
          <p className="text-gray-800 whitespace-pre-line">{responseMsg}</p>
        </div>
      )}
    </div>
  );
}
