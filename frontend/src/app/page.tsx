"use client";

import { useState } from "react";

export default function Home() {
  const [input, setInput] = useState("");
  const [markdownUrl, setMarkdownUrl] = useState<string | null>(null);

  const handleGenerate = () => {
    const markdownContent = `# Codebase Genius\n\n${input}`;
    const blob = new Blob([markdownContent], { type: "text/markdown" });
    const url = URL.createObjectURL(blob);
    setMarkdownUrl(url);
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gray-50 p-6">
      {/* Title */}
      <h1 className="text-4xl font-bold text-gray-900 mb-2">
        Codebase Genius
      </h1>
      
      {/* Subheader */}
      <p className="text-lg text-gray-600 mb-6">
        Telling the Story of Github Repository
      </p>

      {/* Input & Button */}
      <div className="flex flex-col sm:flex-row gap-3 w-full max-w-md">
        <input
          type="text"
          placeholder="Enter your text here..."
          value={input}
          onChange={(e) => setInput(e.target.value)}
          className="flex-1 border border-gray-300 rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <button
          onClick={handleGenerate}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg shadow hover:bg-blue-700 transition"
        >
          Generate
        </button>
      </div>

      {/* Download Button */}
      {markdownUrl && (
        <a
          href={markdownUrl}
          download="output.md"
          className="mt-6 bg-green-600 text-white px-4 py-2 rounded-lg shadow hover:bg-green-700 transition"
        >
          Download Markdown
        </a>
      )}
    </div>
  );
}
