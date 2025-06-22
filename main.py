from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from functions import summarize_text, get_next_question_or_finish
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# ✅ CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 개발 중이므로 모든 origin 허용 (배포 시에는 특정 origin으로 제한 권장)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ConversationRequest(BaseModel):
    conversation: str

class SummaraizeRequest(BaseModel):
    text: str

@app.get("/")
def read_root():
    return {"message": "FastAPI 서버가 정상적으로 작동 중입니다."}

@app.post("/question")
async def question_api(req: ConversationRequest):
    next_step = get_next_question_or_finish(req.conversation)
    return {"next_step": next_step}

@app.post("/summarize")
async def summarize_api(req: SummaraizeRequest):
    summary = summarize_text(req.text)
    return {"summary": summary}

@app.get("/favicon.ico")
def favicon():
    return {}
