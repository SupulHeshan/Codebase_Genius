import re;

with entry {
    high_priority_files = [
    "temp_repo/README.md",
    "temp_repo/rag-system/backend/main.py",
    "temp_repo/rag-system/backend/rag_chain.py",
    "temp_repo/rag-system/backend/improved_rag.py",
    "temp_repo/rag-system/backend/test_pdf.py",
    "temp_repo/rag-system/backend/requirements.txt",
    "temp_repo/rag-system/frontend/package.json",
    "temp_repo/rag-system/frontend/src/app/layout.tsx",
    "temp_repo/rag-system/frontend/src/app/page.tsx",
    "temp_repo/rag-system/docker-compose.yml",
    "temp_repo/rag-system/backend/Dockerfile",
    "temp_repo/rag-system/frontend/Dockerfile"
];
    for file in high_priority_files {
        with open(file, "r") as f {
            content = f.read();
        }
        content+= "This is the code of " + file + " Give the documentation of this code:";
        print(content);
    }
}