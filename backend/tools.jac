import os;
import requests;
import from langchain_community.document_loaders {PyPDFDirectoryLoader, PyPDFLoader, TextLoader}
import from langchain_text_splitters {RecursiveCharacterTextSplitter}
import from langchain.schema.document {Document}
import from langchain_mistralai {MistralAIEmbeddings}
import from langchain_chroma {Chroma}

glob IGNORED_FOLDERS:set[str] = {".git", "node_modules", "__pycache__"};
glob embeddings = MistralAIEmbeddings();


obj RepoMapper{
    has clone_dir:str = "temp_repo";
    has chroma_path: str = "chroma";

    def split_documents(documents: list[Document]) {
        text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000,
        chunk_overlap=100,
        length_function=len,
        separators=[", "],
        is_separator_regex=False);
        return text_splitter.split_documents(documents);
    }

    def document_loader(clone_dir: str){
        ext = os.path.splitext(clone_dir)[1].lower();
        if ext == ".pdf"{
            loader = PyPDFLoader(clone_dir);
        }
        elif ext in {".txt", ".md", ".py", ".java", ".js", ".html", ".css", ".json", ".xml", ".csv"}{
            loader = TextLoader(clone_dir, encoding="utf-8");
        }
        else{
            print(f"Unsupported file type: {ext}. Skipping {clone_dir}.");
            return [];
        }
        return loader.load();
    }

    def add_file1(clone_dir: str){
        documents = self.document_loader(clone_dir);
        chunks = self.split_documents(documents);
        chunks_len = len(chunks);
        self.add_to_chroma(chunks);
    }

    def add_file(clone_dir: str){
        document_dir = self.load_repo_files(clone_dir);
        document = self.document_loader(document_dir);
        self.add_to_chroma(document);
    }

    def readme(clone_dir: str){
        readme_path = os.path.join(clone_dir, "README.md");
        if os.path.exists(readme_path){
            with open(readme_path, "r", encoding="utf-8") as f{
                return f.read();
            }
        }
        return "No README file found.";
    }

    def load_repo_files(clone_dir: str){
        documents = [];

        for (dirpath, dirnames, filenames) in os.walk(clone_dir){
            if ".git" in dirpath or "__pycache__" in dirpath{
                continue;
            }
            for file in filenames{
                file_path = os.path.join(dirpath, file);
                documents.append(file_path);
            }
        }
        doc = ", ".join(documents);
        with open("all_files.txt", "w", encoding="utf-8") as f{
            f.write(doc);
        }

        return os.path.abspath("all_files.txt");
    }

    def add_to_chroma(chunks: list[Document]){
        db = Chroma(persist_directory=self.chroma_path, embedding_function=embeddings);
        db.reset_collection();
        db.add_documents(chunks);
    }

    def get_from_chroma(query: str,chunck_nos: int=10) {
        db = Chroma(
            persist_directory=self.chroma_path,
            embedding_function=embeddings
        );
        results = db.similarity_search_with_score(query,k=chunck_nos);
        return results;
    }

}


