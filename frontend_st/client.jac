import streamlit as st;
import requests;

def bootstrap_frontend(){
    st.set_page_config(layout="wide");
    st.title("Codebase Genius");
    st.subheader("Generate a Markdown file from your input");

    # User input
    user_input = st.text_input("Enter your input (e.g., GitHub link or text):");

    # State to store generated markdown
    if "generated_md" not in st.session_state{
        st.session_state.generated_md = "";
    }

    # Generate button
    if st.button("Generate"){
        if not user_input.strip(){
            st.error("Please enter some input first.");
        }
        else{
            payload = {"message": user_input};
            response = requests.post(
                "http://localhost:8000/walker/clone_repo",
                json=payload
            );
        }
            if response.status_code == 200{
                response = response.json();
                print("response is",response);
                #st.markdown(response["reports"][0]["response"]);
                markdown_text = (
                response.get("response") 
                or response.get("result") 
                or response.get("reports", [{}])[0].get("response") 
                or "⚠️ No markdown found in response"
                );  
                st.write(markdown_text);
                
                st.session_state.generated_md = response["reports"][0]["response"];
                st.success("Markdown generated successfully!");
            }
            else{
                st.error(f"Error: {response.text}");
            }
    }
    # Download button if markdown exists
    if st.session_state.generated_md{
        st.download_button(
            label="Download Markdown",
            data=st.session_state.generated_md,
            file_name="output.md",
            mime="text/markdown"
        );
    }    
}
with entry{
    # INSTANCE_URL = "http://localhost:8000";
    # TEST_USER_EMAIL = "test@mail.com";
    # TEST_USER_PASSWORD = "password";

    # response = requests.post(
    #     f"{INSTANCE_URL}/user/login",
    #     json={"email": TEST_USER_EMAIL, "password": TEST_USER_PASSWORD}
    # );

    # if response.status_code != 200{
    #     # Register if login fails
    #     response = requests.post(
    #         f"{INSTANCE_URL}/user/register",
    #         json={"email": TEST_USER_EMAIL, "password": TEST_USER_PASSWORD}
    #     );
    #     assert 200 <= response.status_code < 300, f"Unexpected status: {response.status_code}, body: {response.text}";


    #     response = requests.post(
    #         f"{INSTANCE_URL}/user/login",
    #         json={"email": TEST_USER_EMAIL, "password": TEST_USER_PASSWORD}
    #     );
    #     assert 200 <= response.status_code < 300, f"Unexpected status: {response.status_code}, body: {response.text}";

    # }
    # token = response.json()["token"];
    # print("Token:", token);

    bootstrap_frontend();
}    
