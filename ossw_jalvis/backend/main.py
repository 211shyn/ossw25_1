from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from functions import speech_to_text_once, summarize_text, get_next_question_or_finish

app = FastAPI()

class ConversationRequest(BaseModel):
    conversation: str

class SummaraizeRequest(BaseModel):
    text: str

@app.get("/stt")
async def stt_api():
    text = speech_to_text_once()
    if text:
        return {"text": text}
    else:
        raise HTTPException(status_code=400, detail="음성 인식 실패")
    

@app.post("/question")
async def question_api(req: ConversationRequest):
    next_step = get_next_question_or_finish(req.conversation)
    return {"next_step": next_step}

@app.post("/summarize")
async def summarize_api(req: SummaraizeRequest):
    summary = summarize_text(req.text)
    return {"summary": summary}
