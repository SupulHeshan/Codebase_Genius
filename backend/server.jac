import sys;
import from mtllm.llm {Model}
import from mtllm.types {Text}
import from tools {RepoMapper}
import os;
import base64;
import requests;
import anyio;
import mcp_client;

glob repo_mapper:RepoMapper = RepoMapper();
glob llm = Model(model_name='gemini/gemini-2.0-flash', verbose=True);
glob MCP_SERVER_URL: str = os.getenv('MCP_SERVER_URL', 'http://localhost:8899/mcp');

enum ChatType {
    CODEBASE = "CODEBASE"   # <-- new type, specialized for Codebase Genius
}

node chat{
    has chat_type:ChatType;
}

node CodeBase(Chat){
    has repo_url:str;
    has repo_mapper:RepoMapper = repo_mapper;
    has context_size:int = 3000;  # Max tokens for context
    has response_size:int = 500;   # Max tokens for response
    has chat_history:list[tuple[str, str]] = [];
    has system_prompt:str = "You are Codebase Genius, an AI assistant specialized in understanding and navigating codebases. Provide clear, concise, and accurate information based on the provided code context.";
    
    def setup{
        self.repo_mapper.repo_url = self.repo_url;
        self.repo_mapper.clone_repo();
        self.repo_mapper.build_file_tree();
        print("Repository cloned and file tree built.");
        self.repo_mapper.read_readme();
    }

    def summarize(content: str, max_words: int) -> str by llm();

}
