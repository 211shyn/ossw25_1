from openai import OpenAI

# 새로운 방식: 클라이언트 객체 생성(API key 생략됨)
client = OpenAI(api_key="sk-여기에_발급받은_API키_입력"
                        ""
                        "")

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
        "2. 만약 사용자가 충분히 대화했다고 판단되면 **반드시 '마무리:'로 시작하는 문장으로** 대화를 마무리하는 멘트를 만들어줘.\n\n"
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

    # ✅ 백업 종료 조건 (GPT가 끝내는 걸 못 알아차릴 경우)
    if "대화가 끝났어" in next_step or "요약해줘" in next_step:
        return "마무리: 오늘 하루를 함께해줘서 고마워요. 푹 쉬고 좋은 밤 되세요!"

    return next_step