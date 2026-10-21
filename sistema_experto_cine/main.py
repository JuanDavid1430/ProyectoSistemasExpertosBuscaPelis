"""Interfaz web de CineExperto para el Entregable 2.

Puede iniciarse con ``streamlit run main.py`` o directamente con
``python main.py``; en el segundo caso el script relanza Streamlit.
"""

from __future__ import annotations

import base64
from html import escape
import mimetypes
from pathlib import Path
import subprocess
import sys

import streamlit as st
from streamlit.runtime.scriptrunner import get_script_run_ctx

from motor import MotorCine


APP_DIR = Path(__file__).resolve().parent
LOGO_PATH = APP_DIR / "assets" / "LogoCineExperto.png"


def asegurar_ejecucion_streamlit() -> None:
    """Relanza la app correctamente cuando se usa ``python main.py``.

    Streamlit necesita crear un ScriptRunContext. Ejecutar el archivo con el
    intérprete normal no crea ese contexto y produce los avisos
    ``missing ScriptRunContext``. El proceso hijo sí se inicia con el CLI
    oficial y conserva el mismo intérprete/entorno virtual.
    """
    if __name__ == "__main__" and get_script_run_ctx(suppress_warning=True) is None:
        comando = [
            sys.executable,
            "-m",
            "streamlit",
            "run",
            str(Path(__file__).resolve()),
        ]
        raise SystemExit(subprocess.call(comando))


asegurar_ejecucion_streamlit()


st.set_page_config(
    page_title="CineExperto · Caja Blanca",
    page_icon="🎬",
    layout="wide",
    initial_sidebar_state="expanded",
)

st.markdown(
    """
    <style>
    @import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Space+Grotesk:wght@600;700&display=swap');
    :root { --ink:#f7f4ff; --muted:#b7b0c8; --violet:#8b5cf6; --cyan:#22d3ee; }
    html { color-scheme: dark; }
    .stApp {
        background:
          radial-gradient(circle at 14% 8%, rgba(124,58,237,.18), transparent 30rem),
          radial-gradient(circle at 92% 12%, rgba(6,182,212,.12), transparent 28rem),
          #0b0911;
        color: var(--ink); font-family:'DM Sans',sans-serif;
    }
    /* Contraste de los componentes nativos de Streamlit. El tema del equipo no
       debe convertir los textos en gris oscuro sobre el fondo de la app. */
    [data-testid="stAppViewContainer"], [data-testid="stMain"] {
        color:#f7f4ff;
    }
    [data-testid="stMarkdownContainer"] p,
    [data-testid="stMarkdownContainer"] li,
    [data-testid="stWidgetLabel"] p,
    [data-testid="stCaptionContainer"] p {
        color:#e9e4f2 !important;
    }
    [data-testid="stCaptionContainer"] p { color:#c9c1d7 !important; }
    [data-testid="stMarkdownContainer"] strong { color:#ffffff !important; }
    [data-testid="stMarkdownContainer"] a { color:#67e8f9 !important; }
    [data-testid="stMarkdownContainer"] code {
        color:#e9d5ff !important; background:#251b35 !important;
        border:1px solid #493561; border-radius:6px; padding:.1rem .32rem;
    }
    [data-testid="stForm"] {
        background:rgba(20,16,29,.78); border:1px solid #3a3049;
        border-radius:18px; padding:1.05rem 1.15rem 1.2rem;
    }
    [data-baseweb="input"] > div,
    [data-baseweb="base-input"],
    [data-testid="stNumberInput"] [data-baseweb="input"] {
        background:#17131f !important; border-color:#554468 !important;
    }
    [data-baseweb="input"] input,
    [data-testid="stTextInput"] input,
    [data-testid="stNumberInput"] input {
        color:#ffffff !important; -webkit-text-fill-color:#ffffff !important;
        caret-color:#67e8f9 !important;
    }
    [data-baseweb="input"] input::placeholder,
    [data-testid="stTextInput"] input::placeholder {
        color:#aaa1ba !important; -webkit-text-fill-color:#aaa1ba !important;
        opacity:1 !important;
    }
    [data-testid="stNumberInput"] button {
        background:#241d30 !important; color:#f7f4ff !important;
        border-color:#554468 !important;
    }
    [data-testid="stNumberInput"] button svg { fill:#f7f4ff !important; }
    [data-testid="stWidgetLabel"] { color:#f7f4ff !important; }
    [data-testid="stWidgetLabel"] p { font-weight:600 !important; }
    [data-testid="stToggle"] label span { color:#eee9f7 !important; }
    [data-testid="stToggle"] [data-baseweb="checkbox"] > div {
        background-color:#30263f;
    }
    button[role="tab"] {
        color:#cfc7dc !important; background:transparent !important;
        border-radius:10px 10px 0 0;
    }
    button[role="tab"] p { color:#cfc7dc !important; font-weight:700 !important; }
    button[role="tab"][aria-selected="true"] {
        color:#ffffff !important; background:#21192e !important;
    }
    button[role="tab"][aria-selected="true"] p { color:#ffffff !important; }
    [data-testid="stExpander"] {
        background:#14101d !important; border:1px solid #393046 !important;
        border-radius:12px !important;
    }
    [data-testid="stExpander"] summary,
    [data-testid="stExpander"] summary p,
    [data-testid="stExpander"] summary span {
        color:#f3eef9 !important; font-weight:650 !important;
    }
    [data-testid="stExpander"] svg { fill:#d8cdfa !important; }
    [data-testid="stMetricLabel"] p { color:#c8bfd5 !important; }
    [data-testid="stMetricValue"] div { color:#ffffff !important; }
    [data-testid="stMetricDelta"] div { color:#9eeaf3 !important; }
    [data-testid="stNotification"] {
        background:#171f2b !important; border:1px solid #305467 !important;
        color:#eefcff !important;
    }
    [data-testid="stNotification"] p { color:#eefcff !important; }
    [data-testid="stCode"] {
        background:#0d0a13 !important; border:1px solid #372d45;
        border-radius:12px;
    }
    [data-testid="stCode"] code { color:#f0eafa !important; }
    hr { border-color:#31293d !important; }
    h1,h2,h3 { font-family:'Space Grotesk',sans-serif !important; letter-spacing:-.03em; }
    h1,h2,h3,h4 { color:#ffffff !important; }
    [data-testid="stSidebar"] { background:#100d18; border-right:1px solid #282235; }
    [data-testid="stSidebar"] p,
    [data-testid="stSidebar"] li { color:#e9e4f2 !important; }
    [data-testid="stSidebar"] [data-testid="stCaptionContainer"] p {
        color:#bdb4ca !important;
    }
    [data-testid="stHeader"] { background:transparent; }
    .block-container { max-width:1180px; padding-top:2rem; padding-bottom:4rem; }
    .hero { padding:2.1rem 0 1.25rem; }
    .eyebrow { color:#a78bfa; font-size:.77rem; font-weight:700; letter-spacing:.16em; text-transform:uppercase; }
    .hero h1 { font-size:clamp(2.4rem,6vw,4.9rem); line-height:.94; margin:.55rem 0 1rem; }
    .gradient { background:linear-gradient(100deg,#c4b5fd 10%,#67e8f9 90%); -webkit-background-clip:text; color:transparent; }
    .hero p { color:#bdb6cd; max-width:690px; font-size:1.08rem; line-height:1.65; }
    .glass { background:linear-gradient(145deg,rgba(31,26,43,.88),rgba(18,15,26,.88)); border:1px solid #30283f; border-radius:22px; padding:1.25rem 1.35rem; box-shadow:0 18px 60px rgba(0,0,0,.22); }
    .film-card { background:linear-gradient(145deg,#17131f,#100d17); border:1px solid #382d49; border-radius:20px; min-height:510px; margin-bottom:.55rem; position:relative; overflow:hidden; box-shadow:0 18px 42px rgba(0,0,0,.28); transition:transform .2s ease,border-color .2s ease; }
    .film-card:hover { transform:translateY(-4px); border-color:#7255a0; }
    .film-card:before { content:''; position:absolute; width:110px; height:110px; border-radius:50%; background:rgba(139,92,246,.13); right:-30px; top:-35px; }
    .poster-frame { width:100%; aspect-ratio:2/3; background:#181220; overflow:hidden; position:relative; }
    .poster-frame img { width:100%; height:100%; display:block; object-fit:cover; }
    .poster-placeholder { width:100%; height:100%; display:flex; flex-direction:column; align-items:center; justify-content:center; text-align:center; padding:1.2rem; background:radial-gradient(circle at 25% 15%,rgba(139,92,246,.42),transparent 38%),linear-gradient(145deg,#251834,#0c0911); }
    .poster-icon { font-size:2.2rem; margin-bottom:.8rem; filter:grayscale(.2); }
    .poster-placeholder strong { color:#fff; font:700 1.08rem 'Space Grotesk'; line-height:1.2; }
    .poster-placeholder small { color:#bfb3cd; margin-top:.45rem; font-size:.72rem; }
    .film-content { padding:1rem 1rem 1.15rem; }
    .rank { color:#6ee7f5; font:700 .72rem 'Space Grotesk'; letter-spacing:.14em; text-transform:uppercase; }
    .film-title { font:700 1.35rem 'Space Grotesk'; margin:.55rem 0 .3rem; color:#fff; }
    .meta { color:#c8c0d3; font-size:.88rem; }
    .reason { color:#f0ebf6; font-size:.94rem; line-height:1.55; margin-top:.9rem; }
    .pill { display:inline-block; background:#2d2340; color:#eee7ff; border:1px solid #584575; border-radius:999px; padding:.25rem .6rem; font-size:.74rem; margin:.55rem .25rem 0 0; }
    .score { color:#67e8f9; font-weight:700; }
    .audit-step { border-left:2px solid #7048bd; padding:0 0 1.1rem 1rem; margin-left:.4rem; }
    .audit-id { display:inline-block; color:#0b0911; background:#a78bfa; border-radius:7px; padding:.16rem .42rem; font-weight:700; font-size:.7rem; }
    .audit-name { color:#fff; font-weight:700; margin-left:.4rem; }
    .audit-detail { color:#d0c8da; font-size:.9rem; margin-top:.35rem; line-height:1.5; }
    .question { background:linear-gradient(135deg,rgba(109,40,217,.26),rgba(8,145,178,.18)); border:1px solid #61489a; border-radius:22px; padding:1.4rem; }
    .question-label { color:#c4b5fd; font-size:.75rem; letter-spacing:.14em; font-weight:700; text-transform:uppercase; }
    .question-main { font:700 1.4rem 'Space Grotesk'; color:#fff; margin:.5rem 0; }
    .detail-meta { color:#c9c1d5; font-size:.92rem; line-height:1.65; }
    .detail-synopsis { color:#eee9f5; font-size:1rem; line-height:1.7; }
    .rating-large { color:#fbbf24; font-size:1.25rem; letter-spacing:.08rem; }
    .review-card { background:#14101c; border:1px solid #352a44; border-radius:14px; padding:1rem 1.05rem; margin:.65rem 0; }
    .review-head { display:flex; justify-content:space-between; gap:.75rem; color:#fff; font-weight:700; }
    .review-source { color:#a78bfa; font-size:.72rem; text-transform:uppercase; letter-spacing:.08em; }
    .review-body { color:#e7e0ef; line-height:1.55; margin:.55rem 0; }
    .review-foot { color:#b7adbf; font-size:.78rem; }
    div[data-testid="stDialog"] > div { background:#0f0c16 !important; color:#f7f4ff !important; }
    div.stButton > button, div.stFormSubmitButton > button { border-radius:12px; font-weight:700; border:1px solid #8b6bd0; background:linear-gradient(100deg,#7131df,#4f46e5); color:#ffffff !important; }
    div.stButton > button p, div.stFormSubmitButton > button p { color:#ffffff !important; }
    div.stButton > button:hover, div.stFormSubmitButton > button:hover { border-color:#c4b5fd; filter:brightness(1.12); }
    div[data-testid="stMetric"] { background:#15111e; border:1px solid #2d2639; padding:1rem; border-radius:16px; }
    .status-ok { color:#5eead4 !important; font-weight:700; }
    .tiny { color:#b8afc4 !important; font-size:.8rem; }

    /* Identidad CineExperto: una interfaz más limpia inspirada en el logo. */
    :root {
        --brand-blue:#20b8ff; --brand-blue-soft:#8edcff;
        --brand-gold:#ffb800; --brand-gold-soft:#ffd66b;
        --surface:#10141b; --surface-raised:#151a23;
        --line:#29313d; --text:#f7f9fc; --muted:#a7b0bd;
    }
    html { color-scheme:dark; }
    .stApp {
        background:
          radial-gradient(circle at 78% -8%,rgba(32,184,255,.09),transparent 27rem),
          radial-gradient(circle at 14% 4%,rgba(255,184,0,.055),transparent 22rem),
          #080a0e;
        color:var(--text); font-family:Inter,"Segoe UI",sans-serif;
    }
    h1,h2,h3 { font-family:Inter,"Segoe UI",sans-serif !important; letter-spacing:-.035em; }
    [data-testid="stSidebar"] {
        background:#0b0e13; border-right:1px solid #202631;
    }
    [data-testid="stHeader"] { background:rgba(8,10,14,.78); backdrop-filter:blur(14px); }
    .block-container { max-width:1240px; padding-top:1.25rem; padding-bottom:3rem; }
    .sidebar-brand { text-align:center; padding:.4rem .25rem .9rem; }
    .sidebar-brand img { width:min(190px,90%); height:auto; display:block; margin:0 auto -.1rem; }
    .sidebar-brand p { color:#9aa5b4 !important; font-size:.76rem; letter-spacing:.11em; text-transform:uppercase; margin:0; }

    .hero {
        display:grid; grid-template-columns:minmax(0,1.45fr) minmax(230px,.55fr);
        align-items:center; gap:2rem; min-height:245px; padding:1.1rem 0 1.35rem;
        border-bottom:1px solid #202631;
    }
    .hero-copy { max-width:770px; }
    .hero-logo { display:flex; justify-content:flex-end; align-items:center; }
    .hero-logo img { width:min(100%,215px); height:auto; filter:drop-shadow(0 18px 42px rgba(0,0,0,.44)); }
    .eyebrow { color:var(--brand-blue-soft); font-size:.72rem; letter-spacing:.18em; }
    .hero h1 { font-size:clamp(2.35rem,4.7vw,4.25rem); line-height:.96; margin:.55rem 0 .8rem; }
    .gradient {
        background:linear-gradient(100deg,#ffffff 4%,var(--brand-blue-soft) 52%,var(--brand-gold-soft) 96%);
        -webkit-background-clip:text; color:transparent;
    }
    .hero p { color:#aeb7c4; max-width:690px; font-size:1.06rem; line-height:1.68; margin:0; }

    [data-testid="stForm"] {
        background:var(--surface); border:1px solid var(--line);
        border-radius:16px; padding:1rem 1.1rem 1.15rem; box-shadow:none;
    }
    [data-baseweb="input"] > div, [data-baseweb="base-input"],
    [data-testid="stNumberInput"] [data-baseweb="input"] {
        background:#0b0e13 !important; border-color:#343e4c !important; border-radius:10px !important;
    }
    [data-baseweb="input"] > div:focus-within, [data-baseweb="base-input"]:focus-within {
        border-color:var(--brand-blue) !important; box-shadow:0 0 0 1px var(--brand-blue) !important;
    }
    [data-baseweb="input"] input, [data-testid="stTextInput"] input,
    [data-testid="stNumberInput"] input { caret-color:var(--brand-gold) !important; }

    div.stButton > button, div.stFormSubmitButton > button {
        border-radius:10px; border:1px solid #ffc52f;
        background:var(--brand-gold); color:#151009 !important;
        box-shadow:none; transition:transform .18s ease,background .18s ease,border-color .18s ease;
    }
    div.stButton > button p, div.stFormSubmitButton > button p { color:#151009 !important; }
    div.stButton > button:hover, div.stFormSubmitButton > button:hover {
        background:#ffc52f; border-color:#ffe094; filter:none; transform:translateY(-1px);
    }

    div[data-testid="stMetric"] {
        background:var(--surface); border:1px solid var(--line); padding:1rem;
        border-radius:13px; box-shadow:none; position:relative; overflow:hidden;
    }
    div[data-testid="stMetric"]:before {
        content:""; position:absolute; inset:0 auto 0 0; width:2px; background:var(--brand-blue);
    }
    [data-testid="stMetricDelta"] div { color:var(--brand-blue-soft) !important; }

    .film-card {
        background:var(--surface); border:1px solid var(--line); border-radius:14px;
        min-height:0; box-shadow:none; transition:transform .2s ease,border-color .2s ease,box-shadow .2s ease;
    }
    .film-card:hover { transform:translateY(-5px); border-color:#3d9dcc; box-shadow:0 18px 42px rgba(0,0,0,.28); }
    .film-card:before { display:none; }
    .poster-frame { background:#0c0f14; }
    .poster-frame img { transition:transform .35s ease; }
    .film-card:hover .poster-frame img { transform:scale(1.025); }
    .poster-placeholder {
        background:linear-gradient(145deg,#121923,#0a0d12);
        border-bottom:1px solid var(--line);
    }
    .film-content { padding:.72rem .78rem .8rem; }
    .rank { color:var(--brand-blue-soft); font-family:Inter,"Segoe UI",sans-serif; }
    .film-title { font-family:Inter,"Segoe UI",sans-serif; font-size:1.08rem; }
    .score { color:var(--brand-gold-soft); }
    .pill { background:#171d26; color:#dce5ef; border:1px solid #323c49; }

    button[role="tab"] { border-radius:8px 8px 0 0; }
    button[role="tab"][aria-selected="true"] { background:#131820 !important; }
    button[role="tab"][aria-selected="true"]:after { background:var(--brand-gold) !important; }
    .audit-step { border-left-color:var(--brand-blue); }
    .audit-id { color:#071019; background:var(--brand-blue-soft); }
    .question { background:#111820; border:1px solid #2b6582; border-radius:14px; }
    .question-label { color:var(--brand-blue-soft); }
    .review-card, [data-testid="stExpander"] {
        background:var(--surface) !important; border-color:var(--line) !important; border-radius:12px !important;
    }
    .review-source { color:var(--brand-blue-soft); }
    .rating-large { color:var(--brand-gold); }
    div[data-testid="stDialog"] > div { background:#0b0e13 !important; }
    .status-ok { color:#66e3ba !important; }
    hr { border-color:#202631 !important; }

    /* Buscador tipo portal de cine. */
    .st-key-search_area {
        position:relative; margin:.15rem 0 .9rem; padding:1rem 1.2rem .9rem;
        overflow:hidden; border:1px solid #2a323e; border-radius:18px;
        background:linear-gradient(115deg,#121720 0%,#0e1218 68%,#17150d 100%);
    }
    .st-key-search_area:after {
        content:""; position:absolute; width:250px; height:250px; border-radius:50%;
        right:-125px; top:-165px; pointer-events:none;
        background:rgba(255,184,0,.12); filter:blur(4px);
    }
    .search-kicker {
        color:var(--brand-gold-soft); font-size:.7rem; font-weight:800;
        letter-spacing:.17em; text-transform:uppercase; margin-bottom:.35rem;
    }
    .search-title { color:#fff; font-size:clamp(1.35rem,2.3vw,2rem); font-weight:750; letter-spacing:-.03em; }
    .search-copy { color:#9fa9b6; font-size:.86rem; margin:.15rem 0 .65rem; }
    .st-key-search_area [data-testid="stForm"] {
        position:relative; z-index:1; padding:0; border:0; border-radius:12px;
        background:transparent; box-shadow:none;
    }
    .st-key-search_area [data-testid="stHorizontalBlock"] { align-items:stretch; gap:.7rem; }
    .st-key-search_area [data-testid="stTextInput"] { margin:0; }
    .st-key-search_area [data-baseweb="input"] > div,
    .st-key-search_area [data-baseweb="base-input"] {
        min-height:3.25rem; background:#080b10 !important; border-color:#394454 !important;
        border-radius:11px !important;
    }
    .st-key-search_area [data-testid="stTextInput"] input { font-size:1rem; padding-left:1.05rem; }
    .st-key-search_area div.stFormSubmitButton > button {
        min-height:3.25rem; width:100%; white-space:nowrap; font-size:.93rem;
    }
    .search-examples { display:flex; align-items:center; flex-wrap:wrap; gap:.38rem; margin-top:.6rem; }
    .search-examples > span:first-child { color:#7f8997; font-size:.76rem; margin-right:.15rem; }
    .search-chip {
        display:inline-flex; align-items:center; min-height:1.85rem; padding:.28rem .65rem;
        color:#cbd4de; background:#171d25; border:1px solid #303a47;
        border-radius:999px; font-size:.74rem;
    }

    /* Resumen fluido: evita columnas cortadas en portátiles y tabletas. */
    .result-summary {
        display:grid; grid-template-columns:repeat(auto-fit,minmax(155px,1fr));
        gap:.6rem; margin:.15rem 0 1rem;
    }
    .summary-card {
        min-width:0; padding:.68rem .8rem; background:#10151c;
        border:1px solid #29323e; border-radius:12px;
    }
    .summary-label { color:#8f9aa8; font-size:.7rem; font-weight:700; letter-spacing:.09em; text-transform:uppercase; }
    .summary-value {
        color:#f8fafc; font-size:1.08rem; font-weight:720; line-height:1.3;
        margin-top:.3rem; overflow-wrap:anywhere;
    }
    .summary-card.is-online { border-color:#245447; }
    .summary-card.is-online .summary-value { color:#73e2bd; }
    .summary-dot {
        display:inline-block; width:.48rem; height:.48rem; border-radius:50%;
        background:#56d8aa; margin-right:.4rem; box-shadow:0 0 0 4px rgba(86,216,170,.09);
    }

    .section-heading { display:flex; align-items:end; justify-content:space-between; gap:1rem; margin:.45rem 0 1.1rem; }
    .section-heading h3 { margin:0; font-size:clamp(1.45rem,2.5vw,2rem); }
    .section-heading p { margin:.3rem 0 0; color:#929dab !important; font-size:.88rem; }
    .section-count { color:var(--brand-gold-soft); font-size:.76rem; font-weight:800; letter-spacing:.1em; white-space:nowrap; }
    .film-rank-row { display:flex; align-items:center; justify-content:space-between; gap:.45rem; }
    .film-rank-row .rank { font-size:.63rem; white-space:nowrap; }
    .film-rank-row .score, .film-rank-row .meta { font-size:.7rem; white-space:nowrap; }
    .film-title { min-height:2.55rem; display:flex; align-items:center; margin:.35rem 0 .12rem; line-height:1.16; }
    .film-meta { color:#aeb7c4; font-size:.76rem; line-height:1.35; }
    .film-genres {
        color:#d3dbe5; font-size:.72rem; line-height:1.35; white-space:nowrap;
        overflow:hidden; text-overflow:ellipsis; margin-top:.35rem;
    }
    .reason {
        min-height:2.55rem; margin-top:.48rem; font-size:.78rem; line-height:1.38;
        display:-webkit-box; -webkit-box-orient:vertical; -webkit-line-clamp:2; overflow:hidden;
    }
    .st-key-movie_grid div.stButton > button {
        min-height:2.35rem; padding:.35rem .6rem; font-size:.82rem; margin-top:-.18rem;
    }
    .sidebar-query {
        color:#dbe3ec; background:#121720; border:1px solid #29323e;
        border-radius:10px; padding:.68rem .75rem; margin:.48rem 0;
        font-size:.78rem; line-height:1.38; overflow-wrap:anywhere;
    }

    @media (max-width:900px) {
        .st-key-movie_grid [data-testid="stHorizontalBlock"] { flex-wrap:wrap; }
        .st-key-movie_grid [data-testid="stColumn"] {
            flex:1 1 calc(50% - .6rem) !important; width:calc(50% - .6rem) !important;
            min-width:260px !important;
        }
    }

    @media (max-width:760px) {
        .block-container { padding-top:.75rem; }
        .hero { grid-template-columns:1fr; min-height:auto; padding:1.3rem 0 1.8rem; }
        .hero-logo { justify-content:center; order:-1; }
        .hero-logo img { width:180px; }
        .hero h1 { font-size:2.6rem; }
        .st-key-search_area { padding:1.1rem; }
        .st-key-search_area [data-testid="stHorizontalBlock"] { gap:.45rem; flex-wrap:wrap; }
        .st-key-search_area [data-testid="stColumn"] {
            flex:1 1 100% !important; width:100% !important; min-width:0 !important;
        }
        .result-summary { grid-template-columns:repeat(2,minmax(0,1fr)); }
        .section-heading { align-items:flex-start; flex-direction:column; }
        .st-key-movie_grid [data-testid="stColumn"] {
            flex:1 1 100% !important; width:100% !important; min-width:0 !important;
        }
    }
    @media (max-width:430px) {
        .result-summary { grid-template-columns:1fr; }
        .hero h1 { font-size:2.25rem; }
    }
    </style>
    """,
    unsafe_allow_html=True,
)


@st.cache_resource(show_spinner=False)
def cargar_motor() -> MotorCine:
    return MotorCine()


POSTERS_DIR = APP_DIR / "assets" / "posters"
EXTENSIONES_POSTER = (".webp", ".jpg", ".jpeg", ".png")
PELICULAS_CARTELERA = (
    "el_conjuro", "it", "annabelle", "toy_story", "nemo", "intensamente",
    "coco", "encanto", "shrek", "villano", "deadpool", "joker",
    "coraline", "hotel", "titanic",
)


def ruta_poster(pelicula_id: str) -> Path | None:
    """Encuentra el póster suministrado por el equipo, si ya está disponible."""
    for extension in EXTENSIONES_POSTER:
        candidata = POSTERS_DIR / f"{pelicula_id}{extension}"
        if candidata.is_file():
            return candidata
    return None


@st.cache_data(show_spinner=False)
def imagen_a_data_uri(ruta: str, ultima_modificacion: float) -> str:
    """Incrusta un archivo local sin depender de servidores de imágenes."""
    del ultima_modificacion  # Forma parte de la clave para invalidar la caché.
    archivo = Path(ruta)
    mime = mimetypes.guess_type(archivo.name)[0] or "image/jpeg"
    contenido = base64.b64encode(archivo.read_bytes()).decode("ascii")
    return f"data:{mime};base64,{contenido}"


def logo_data_uri() -> str:
    """Devuelve el logo del proyecto listo para la cabecera y el menú lateral."""
    if not LOGO_PATH.is_file():
        return ""
    return imagen_a_data_uri(str(LOGO_PATH), LOGO_PATH.stat().st_mtime)


def poster_html(pelicula: dict) -> str:
    ruta = ruta_poster(str(pelicula["id"]))
    titulo = escape(str(pelicula["titulo"]))
    if ruta:
        uri = imagen_a_data_uri(str(ruta), ruta.stat().st_mtime)
        return f'<div class="poster-frame"><img src="{uri}" alt="Póster de {titulo}"></div>'
    return f"""
    <div class="poster-frame"><div class="poster-placeholder">
      <div class="poster-icon">🎬</div><strong>{titulo}</strong>
      <small>Póster pendiente de suministrar</small>
    </div></div>"""


def tarjeta_pelicula(pelicula: dict, puesto: int) -> str:
    """Construye la tarjeta visual; la decisión continúa viniendo de Prolog."""
    generos = " · ".join(
        escape(str(g).title()) for g in pelicula["generos"]
    )
    titulo = escape(str(pelicula["titulo"]))
    motivo = escape(str(pelicula["justificacion_principal"]))
    nivel = escape(str(pelicula["nivel_coincidencia"]).replace("_", " ").title())
    calificacion = float(pelicula.get("calificacion_promedio", 0))
    valoracion = (
        f'<span class="score">★ {calificacion:.1f}/5</span>'
        if calificacion > 0
        else '<span class="meta">Sin reseñas</span>'
    )
    return f"""
    <div class="film-card">
      {poster_html(pelicula)}
      <div class="film-content">
        <div class="film-rank-row">
          <span class="rank">#{puesto:02d} · {nivel}</span>{valoracion}
        </div>
        <div class="film-title">{titulo}</div>
        <div class="film-meta">{pelicula['anio']} · {pelicula['edad_minima']}+ ·
          <span class="score">{pelicula['puntaje_total']} pts</span></div>
        <div class="film-genres" title="{generos}">{generos}</div>
        <div class="reason" title="{motivo}">{motivo}</div>
      </div>
    </div>
    """


def mostrar_resultados(datos: dict) -> None:
    resultados = datos["resultados"]
    if not resultados:
        estados = {
            "consulta_vacia": "Escribe una preferencia para iniciar la inferencia.",
            "criterio_no_reconocido": "No reconocí criterios del vocabulario experto.",
            "sin_resultados": "Ninguna película supera los filtros indicados.",
        }
        st.info(estados.get(datos["estado"], "No hay resultados para mostrar."))
        return

    st.markdown(
        f'''<div class="section-heading">
        <div><h3>Cartelera recomendada</h3>
        <p>Abre una película para conocer su historia, explicación y reseñas.</p></div>
        <div class="section-count">{len(resultados)} PELÍCULAS PARA TI</div>
        </div>''',
        unsafe_allow_html=True,
    )
    # Cuatro columnas imitan una cartelera compacta. Las reglas CSS reducen la
    # rejilla a dos columnas en tableta y una en móvil.
    with st.container(key="movie_grid"):
        for inicio in range(0, len(resultados), 4):
            columnas = st.columns(4, gap="small")
            for desplazamiento, columna in enumerate(columnas):
                indice = inicio + desplazamiento
                if indice < len(resultados):
                    pelicula = resultados[indice]
                    with columna:
                        st.markdown(
                            tarjeta_pelicula(pelicula, indice + 1),
                            unsafe_allow_html=True,
                        )
                        if st.button(
                            "Ver película",
                            key=f"detalle_{pelicula['id']}",
                            use_container_width=True,
                        ):
                            st.session_state.pelicula_seleccionada = pelicula["id"]
                            st.rerun()


def resumen_busqueda_html(datos: dict) -> str:
    """Resumen adaptable que no trunca estados largos en pantallas medianas."""
    estado = escape(
        str(datos["decision"]["estado"]).replace("_", " ").title()
    )
    total = int(datos["total"])
    criterios = len(datos["criterios"])
    return f"""
    <div class="result-summary" aria-label="Resumen de la consulta">
      <div class="summary-card">
        <div class="summary-label">Estado de inferencia</div>
        <div class="summary-value">{estado}</div>
      </div>
      <div class="summary-card">
        <div class="summary-label">Coincidencias</div>
        <div class="summary-value">{total} películas</div>
      </div>
      <div class="summary-card">
        <div class="summary-label">Criterios detectados</div>
        <div class="summary-value">{criterios}</div>
      </div>
      <div class="summary-card is-online">
        <div class="summary-label">Motor de conocimiento</div>
        <div class="summary-value"><span class="summary-dot"></span>Prolog conectado</div>
      </div>
    </div>
    """


def mostrar_auditoria(datos: dict) -> None:
    auditoria = datos["auditoria"]
    if not auditoria["hipotesis_principal"]:
        st.info("La traza aparecerá cuando exista al menos una hipótesis activa.")
        return

    st.markdown(
        f"La hipótesis principal auditada es "
        f"`{auditoria['hipotesis_principal']}`. Todo lo siguiente fue devuelto por Prolog."
    )
    izquierda, derecha = st.columns([1.05, 1], gap="large")
    with izquierda:
        st.markdown("#### Reglas disparadas")
        for regla in auditoria["reglas_disparadas"]:
            st.markdown(
                f"""<div class="audit-step"><span class="audit-id">{escape(str(regla['id']).upper())}</span>
                <span class="audit-name">{escape(str(regla['nombre']))}</span>
                <div class="audit-detail">{escape(str(regla['detalle']))}</div></div>""",
                unsafe_allow_html=True,
            )
    with derecha:
        st.markdown("#### Hechos comprobados")
        st.code("\n".join(auditoria["hechos_verdaderos"]), language="prolog")
        st.markdown("#### Hipótesis descartadas")
        if auditoria["hipotesis_descartadas"]:
            for alternativa in auditoria["hipotesis_descartadas"]:
                st.markdown(
                    f"- **{alternativa['titulo']}** — {alternativa['motivo']}"
                )
        else:
            st.caption("No hubo hipótesis alternativas para descartar.")


def mostrar_faltante(datos: dict) -> None:
    decision = datos["decision"]
    recomendacion = decision["recomendacion"]
    estado = str(decision["estado"]).replace("_", " ").title()
    st.markdown(
        f"""<div class="question">
        <div class="question-label">Qué falta · {escape(estado)}</div>
        <div class="question-main">{escape(str(recomendacion['pregunta']))}</div>
        <div class="audit-detail">{escape(str(recomendacion['motivo']))}</div>
        </div>""",
        unsafe_allow_html=True,
    )
    st.markdown("#### Hipótesis en competencia")
    competencia = decision["hipotesis_competencia"]
    if competencia:
        columnas = st.columns(min(3, len(competencia)))
        for indice, hipotesis in enumerate(competencia):
            with columnas[indice % len(columnas)]:
                st.metric(
                    hipotesis["titulo"],
                    f"{hipotesis['puntaje']} pts",
                    f"Cobertura {hipotesis['cobertura']}",
                    delta_color="off",
                )
    else:
        st.caption("No hay hipótesis activas; reformula la consulta.")


def estrellas(calificacion: int | float) -> str:
    cantidad = max(0, min(5, round(float(calificacion))))
    return "★" * cantidad + "☆" * (5 - cantidad)


def tarjeta_resena(resena: dict) -> str:
    autor = escape(str(resena["autor"]).replace("_", " ").title())
    texto = escape(str(resena["texto"]))
    percepcion = escape(str(resena["percepcion"]).replace("_", " ").title())
    origen = "Comunidad" if resena["origen"] == "usuario" else "Base inicial"
    calificacion = int(resena.get("calificacion", 0))
    valoracion = estrellas(calificacion) if calificacion else "Opinión sin calificación"
    fecha = escape(str(resena.get("fecha", "")))
    return f"""
    <div class="review-card">
      <div class="review-head"><span>{autor}</span><span class="review-source">{origen}</span></div>
      <div class="rating-large">{valoracion}</div>
      <div class="review-body">{texto}</div>
      <div class="review-foot">Percepción: {percepcion} · {fecha}</div>
    </div>"""


@st.dialog("Ficha de la película", width="large")
def mostrar_ficha(pelicula_id: str) -> None:
    """Ficha tipo portal de cine con opiniones y captura persistente."""
    try:
        detalle = motor.detalle(pelicula_id)
    except Exception as exc:
        st.error(f"No fue posible cargar la ficha: {exc}")
        return

    mensaje = st.session_state.pop("mensaje_resena", None)
    if mensaje:
        st.success(mensaje)

    poster, informacion = st.columns([0.38, 0.62], gap="large")
    with poster:
        st.markdown(poster_html(detalle), unsafe_allow_html=True)
    with informacion:
        st.markdown(f"## {detalle['titulo']}")
        generos = " · ".join(str(g).title() for g in detalle["generos"])
        st.markdown(
            f'<div class="detail-meta">{detalle["anio"]} · '
            f'{detalle["edad_minima"]}+ · {escape(generos)}</div>',
            unsafe_allow_html=True,
        )
        if float(detalle["calificacion_promedio"]) > 0:
            promedio = float(detalle["calificacion_promedio"])
            st.markdown(
                f'<div class="rating-large">{estrellas(promedio)} '
                f'<span class="detail-meta">{promedio:.1f}/5</span></div>',
                unsafe_allow_html=True,
            )
        else:
            st.caption("Esta película todavía no tiene calificaciones de la comunidad.")
        st.markdown("#### Sinopsis")
        st.markdown(
            f'<div class="detail-synopsis">{escape(str(detalle["sinopsis"]))}</div>',
            unsafe_allow_html=True,
        )
        etiquetas = "".join(
            f'<span class="pill">{escape(str(e).title())}</span>'
            for e in detalle["etiquetas"]
        )
        st.markdown(etiquetas, unsafe_allow_html=True)

    resultado_actual = next(
        (
            pelicula
            for pelicula in st.session_state.respuesta.get("resultados", [])
            if pelicula["id"] == pelicula_id
        ),
        None,
    )
    if resultado_actual:
        with st.expander("¿Por qué apareció en esta búsqueda?"):
            for evidencia in resultado_actual["evidencias"]:
                st.markdown(
                    f"- **{evidencia['origen']} · {evidencia['puntaje']} pts:** "
                    f"{evidencia['justificacion']}"
                )

    st.markdown(f"### Reseñas ({detalle['total_resenas']})")
    if detalle["resenas"]:
        for resena in detalle["resenas"]:
            st.markdown(tarjeta_resena(resena), unsafe_allow_html=True)
    else:
        st.info("Aún no hay opiniones. Puedes publicar la primera reseña.")

    st.markdown("### Agregar una reseña")
    st.caption(
        "La calificación actualiza el orden de resultados. Una percepción compartida "
        "por dos autores distintos se convierte en evidencia para futuras búsquedas."
    )
    percepciones = {
        "divertida": "Divertida / alegre",
        "terror": "Aterradora",
        "emocionante": "Emocionante / emotiva",
        "suspenso": "Con suspenso",
        "romance": "Romántica",
        "familiar": "Familiar",
    }
    with st.form(f"nueva_resena_{pelicula_id}", clear_on_submit=True):
        autor = st.text_input(
            "Tu nombre",
            max_chars=60,
            placeholder="Ej.: Laura Martínez",
            key=f"autor_{pelicula_id}",
        )
        calificacion = st.select_slider(
            "Calificación",
            options=[1, 2, 3, 4, 5],
            value=5,
            format_func=lambda valor: f"{estrellas(valor)}  {valor}/5",
            key=f"calificacion_{pelicula_id}",
        )
        percepcion = st.selectbox(
            "Percepción principal",
            options=list(percepciones),
            format_func=percepciones.get,
            key=f"percepcion_{pelicula_id}",
        )
        comentario = st.text_area(
            "Comentario",
            max_chars=600,
            height=120,
            placeholder="Cuenta qué te gustó, qué sensación te dejó o con quién la recomendarías…",
            key=f"comentario_{pelicula_id}",
        )
        publicar = st.form_submit_button(
            "Publicar reseña",
            type="primary",
            use_container_width=True,
        )

    if publicar:
        try:
            respuesta = motor.agregar_resena(
                pelicula_id,
                autor,
                comentario,
                percepcion,
                int(calificacion),
            )
            st.session_state.mensaje_resena = respuesta["mensaje"]
            st.session_state.respuesta = motor.buscar(
                st.session_state.get("consulta_actual", "películas divertidas"),
                st.session_state.get("edad_actual"),
            )
            st.rerun()
        except Exception as exc:
            st.error(f"No se pudo guardar la reseña: {exc}")

    if st.button("Cerrar ficha", key=f"cerrar_{pelicula_id}", use_container_width=True):
        st.session_state.pelicula_seleccionada = None
        st.rerun()


try:
    motor = cargar_motor()
except Exception as exc:
    st.error(f"No fue posible iniciar el motor: {exc}")
    st.stop()

with st.sidebar:
    logo_uri = logo_data_uri()
    if logo_uri:
        st.markdown(
            f'''<div class="sidebar-brand">
            <img src="{logo_uri}" alt="CineExperto">
            <p>Sistema experto auditable</p>
            </div>''',
            unsafe_allow_html=True,
        )
    else:
        st.markdown("## CineExperto")
        st.caption("Sistema experto auditable")
    st.markdown("---")
    usar_edad = st.toggle("Aplicar filtro de edad", value=False)
    edad = st.number_input(
        "Edad del espectador",
        min_value=0,
        max_value=120,
        value=18,
        disabled=not usar_edad,
    )
    st.markdown("#### Consultas para la demo")
    st.markdown(
        '''<div class="sidebar-query">Películas de romance</div>
        <div class="sidebar-query">Películas divertidas</div>
        <div class="sidebar-query">Películas infantiles de aventura</div>''',
        unsafe_allow_html=True,
    )
    st.markdown("---")
    conectado = motor.comprobar_conexion()
    if conectado:
        st.markdown('<span class="status-ok">● Motor Prolog conectado</span>', unsafe_allow_html=True)
    posters_disponibles = sum(
        ruta_poster(str(pelicula_id)) is not None
        for pelicula_id in PELICULAS_CARTELERA
    )
    st.caption(f"Pósters de cartelera: {posters_disponibles}/{len(PELICULAS_CARTELERA)}")
    st.markdown('<p class="tiny">PySwip transmite un JSON; Python no decide resultados.</p>', unsafe_allow_html=True)

logo_portada = (
    f'<div class="hero-logo"><img src="{logo_data_uri()}" alt="Logo CineExperto"></div>'
    if logo_data_uri()
    else ""
)
st.markdown(
    f"""<section class="hero">
    <div class="hero-copy">
      <div class="eyebrow">Motor simbólico · Explicabilidad total</div>
      <h1>Tu próxima película,<br><span class="gradient">con razones visibles.</span></h1>
      <p>Describe qué quieres ver. CineExperto consulta su base Prolog, muestra la
      recomendación y abre la caja negra: reglas, hechos, descartes y la pregunta
      exacta que falta para resolver un empate.</p>
    </div>
    {logo_portada}
    </section>""",
    unsafe_allow_html=True,
)

with st.container(key="search_area"):
    st.markdown(
        '''<div class="search-kicker">Cartelera inteligente</div>
        <div class="search-title">¿Qué película quieres descubrir?</div>
        <div class="search-copy">Describe un género, una emoción o el tipo de historia que quieres ver.</div>''',
        unsafe_allow_html=True,
    )
    with st.form("busqueda", clear_on_submit=False):
        campo_busqueda, accion_busqueda = st.columns(
            [4.6, 1.4], gap="small", vertical_alignment="bottom"
        )
        with campo_busqueda:
            consulta = st.text_input(
                "¿Qué te gustaría ver?",
                value="películas divertidas",
                placeholder="Ej.: una aventura familiar, terror paranormal o una historia romántica…",
                max_chars=240,
                label_visibility="collapsed",
            )
        with accion_busqueda:
            buscar = st.form_submit_button(
                "Buscar películas",
                use_container_width=True,
            )
    st.markdown(
        '''<div class="search-examples"><span>Prueba con:</span>
        <span class="search-chip">Aventura familiar</span>
        <span class="search-chip">Terror paranormal</span>
        <span class="search-chip">Comedia animada</span>
        <span class="search-chip">Historia romántica</span></div>''',
        unsafe_allow_html=True,
    )

if buscar or "respuesta" not in st.session_state:
    try:
        with st.spinner("Consultando reglas y construyendo la traza…"):
            edad_consulta = int(edad) if usar_edad else None
            st.session_state.consulta_actual = consulta
            st.session_state.edad_actual = edad_consulta
            if buscar:
                st.session_state.pelicula_seleccionada = None
            st.session_state.respuesta = motor.buscar(
                consulta, edad_consulta
            )
    except Exception as exc:
        st.error(f"La consulta no pudo completarse: {exc}")
        st.stop()

datos = st.session_state.respuesta
st.markdown(resumen_busqueda_html(datos), unsafe_allow_html=True)

tab_resultados, tab_por_que, tab_falta = st.tabs(
    ["🎞️ Resultados", "🔎 ¿Por qué?", "🧭 ¿Qué falta?"]
)
with tab_resultados:
    mostrar_resultados(datos)
with tab_por_que:
    mostrar_auditoria(datos)
with tab_falta:
    mostrar_faltante(datos)

pelicula_seleccionada = st.session_state.get("pelicula_seleccionada")
if pelicula_seleccionada:
    mostrar_ficha(pelicula_seleccionada)

st.markdown("---")
st.caption(
    "Prototipo académico. Edades, etiquetas y opiniones son datos didácticos; "
    "no corresponden a clasificaciones oficiales."
)
