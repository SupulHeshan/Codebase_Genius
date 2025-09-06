# 🧠 Codebase Genius

The primary objective of this project is to create an agentic system that accepts a GitHub repository URL and produces quality Markdown documentation. The system is designed to be particularly effective for repositories written in Python and Jac. A key feature is the automatic generation of visual diagrams to represent the codebase's structure and flow.

## 🎬 Demo Video


https://github.com/user-attachments/assets/09eecfd8-289c-4382-a3e3-bef1888be59b


## ➡️ High-Level Workflow
The process is broken down into a sequence of clear steps. The agent will first understand the "what" and "where" of the code and then dive deeper to understand the "how."

- Clone the Repo: Download the GitHub repository.
- Get File and Folder Structure: Map out the repository's layout.
- Retrieve and Analyze README.md: Read the README for a project overview.
- High-Level Planning: Create a documentation plan using the initial data.
- Iteratively Analyze Code Content: Parse source files to understand the code.
- Generate the Documentation: Create a comprehensive Markdown document.


## 🏛️ Proposed Architecture: A Multi-Agent System 🤖
To accomplish this, a multi-agent architecture was used. Think of it as a team of specialized AI agents managed with a supervisor.

###  Components

- Repo Mapper: 🗺️ Analyzes structure and README.
- Code Analyzer: 👨‍💻 Parses and understands source code.
- DocGenie: 📝 Produces the documentation and diagrams.

### Agent Responsibilities

- Repo Mapper 📂
  - This agent was made responsible for high-level repository mapping.
  - File Tree Generator: 🌳 A structured view of the file system was built, ignoring unnecessary files and folders (e.g., .git, node_modules, etc.).
  - Readme Summarizer: 📖 This was created to extract a concise summary from the README.md file to provide context for the documentation process.

- Code Analyzer 🔬
  - This agent was designed to perform in-depth code analysis.
  - It uses tools such as Tree-sitter for parsing.
  - It identifies functions, classes, and their relationships.
  - It builds the foundation for understanding code logic and interaction.

- DocGenie ✍️
  - This agent was designed to be responsible for generating documentation.
  - It converts structured code insights into human-readable Markdown.
 

## 📥Inputs & Outputs
- **Input**: ➡️ A GitHub repository URL (public repo for MVP).
- **Output**: 📄 Markdown (.md) files saved locally, containing comprehensive documentation of the repository.

## 🚀 Getting Started

### Prerequisites

- jaclang [Jac and Jaseci](https://www.jac-lang.org "Python Supercharged for AI Development at Scale ")
- streamlit
- Mistral API key

### Star with Streamlit

1. Backend Setup: Terminal 1
   ```bash
   python -m venv jac-env
   source jac-env/bin/activate  # or `jac-env\Scripts\activate` on Windows 
   pip install -r requirements.txt
   cd backend
   export "MISTRAL_API_KEY=your-api-key-here" > .env
   export 'MISTRAL_API_KEY'="your api key"
   export 'HF_KEY'="your hf key"
   export REQUIRE_AUTH_BY_DEFAULT=false
   jac serve server.jac
   ```

2. Frontend Setup: Terminal 2
   ```bash
   source jac-env/bin/activate
   cd frontend
   pip install jac streamlit
   jac streamlit client.jac
   ```


## 🔧 Configuration

The following environment variables can be set in the `.env` file in the `rag-system` directory:

- `MISTRAL_API_KEY`: Your Mistral AI API key.
- `HF_KEY` : your HuggingFace Access Token Key
- `CHUNK_SIZE`: The size of the chunks the document is split into (default: 1000).
- `CHUNK_OVERLAP`: The number of overlapping characters between chunks (default: 100).
- `TOP_K`: The number of chunks to retrieve from the vector store (default: 10).

## 🙏 Acknowledgments

- Mistral AI for the language model
- LangChain for the RAG implementation
- Chroma for Vector Database

## 🔗 API Reference
Your application exposes these main endpoints:

- `POST /user/register` — Create a new user account
- `POST /user/login` — Login and get an access token
- `POST /walker/upload_file` — Upload files (requires authentication)
- `POST /walker/interact` — Chat with the AI (requires authentication)

  
Visit `http://localhost:8000/docs` to see the full API documentation.
