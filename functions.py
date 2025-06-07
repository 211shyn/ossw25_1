import speech_recognition as sr
from openai import OpenAI

# 새로운 방식: 클라이언트 객체 생성(API key 생략됨)
client = OpenAI(api_key="sk-여기에_발급받은_API키_입력")

def speech_to_text_once():
    """
    한 번만 음성을 인식해 텍스트로 변환 후 반환하는 함수.
    """
    recognizer = sr.Recognizer()

    with sr.Microphone() as source:
        recognizer.adjust_for_ambient_noise(source)
        print("듣고 있어요...")

        try:
            audio = recognizer.listen(source, timeout=5)
            text = recognizer.recognize_google(audio, language='ko-KR')
            print("인식된 텍스트:", text)
            return text
        except sr.WaitTimeoutError:
            print("시간 초과: 아무 소리도 감지하지 못함")
            return None
        except sr.UnknownValueError:
            print("음성을 인식할 수 없음")
            return None
        except sr.RequestError as e:
            print(f"요청 실패: {e}")
            return None


def summarize_text(text):
    prompt = (
        "다음 내용을 한국어로 3~5줄로 요약해줘:\n\n"
        f"{text}\n\n"
        "요약:"
    )

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "너는 유능한 요약가야."},
            {"role": "user", "content": prompt}
        ],
        temperature=0.7
    )

    summary = response.choices[0].message.content
    return summary


def get_next_question_or_finish(conversation: str):
    prompt = (
        "너는 친근한 비서 역할을 하고 있어. "
        "사용자의 오늘 하루를 자연스럽게 기록하도록 대화를 이어가고 있어. "
        "대화 내용 전체를 참고해서:\n"
        "1. 만약 사용자가 아직 더 이야기할 수 있을 것 같으면 다음 질문을 한 문장으로 만들어줘.\n"
        "2. 만약 사용자가 충분히 대화했다고 판단되면 대화를 마무리하는 멘트를 만들어줘.\n\n"
        f"대화 내용:\n{conversation}\n\n"
        "비서의 답변:"
    )

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "너는 친근하고 따뜻한 비서야."},
            {"role": "user", "content": prompt}
        ],
        temperature=0.7
    )

    next_step = response.choices[0].message.content.strip()
    return next_step