from pathlib import Path
import re,json
from pypdf import PdfReader
from pdf2image import convert_from_path
from docx import Document

root=Path(__file__).resolve().parents[1]
txt=(root/'Baiqau_tusindirme_zhazba.txt').read_text(encoding='utf-8')
doc=Document(root/'Baiqau_tusindirme_zhazba.docx')
pdf=root/'qa'/'Baiqau_preview.pdf'
pages=PdfReader(pdf).pages
texts=[p.extract_text() for p in pages]
figs=re.findall(r'^Сурет (\d+\.\d+)\.',txt,re.M)
tabs=re.findall(r'^Кесте (\d+\.\d+)\.',txt,re.M)
for num in figs:
    prefix=txt.split('Сурет '+num+'.',1)[0].rsplit('[ОСЫ ЖЕРГЕ',1)[0]
    assert re.search(re.escape(num)+r'[- ]сурет',prefix),num
for num in tabs:
    prefix=txt.split('Кесте '+num+'.',1)[0]
    assert re.search(re.escape(num)+r'[- ]кесте',prefix),num
assert list(dict.fromkeys(re.findall(r'\[(\d+)\]',txt)))==[str(i) for i in range(1,13)]
assert len(figs)==13 and len(tabs)==7
assert all(not r.bold and not r.underline for p in doc.paragraphs for r in p.runs)
assert abs(doc.sections[0].left_margin.cm-3)<.01
assert abs(doc.sections[0].right_margin.cm-1)<.01
assert doc.styles['Normal'].font.size.pt==14
assert doc.styles['Normal'].paragraph_format.line_spacing==1.5
appendix_page=next(i+1 for i,t in enumerate(texts) if 'ҚОСЫМШАЛАР' in t and i>1)
intro_page=next(i+1 for i,t in enumerate(texts) if 'КІРІСПЕ' in t and i>0)
main_start=next(i+1 for i,t in enumerate(texts) if '1 БАЙҚАУЛАРДЫ' in t and i>0)
conclusion_page=next(i+1 for i,t in enumerate(texts) if 'ҚОРЫТЫНДЫ' in t and i>0)
refs_page=next(i+1 for i,t in enumerate(texts) if 'ПАЙДАЛАНЫЛҒАН ӘДЕБИЕТТЕР' in t and i>0)
report={'total_pages':len(pages),'without_appendices':appendix_page-1,'introduction_pages':main_start-intro_page,'main_body_pages':conclusion_page-main_start,'conclusion_pages':refs_page-conclusion_page,'figures':figs,'tables':tabs,'sources':12,'words':len(txt.split()),'page_starts':[{str(i+1):t.replace('\n',' ')[:110]} for i,t in enumerate(texts)]}
assert 20<=report['without_appendices']<=30
assert 1<=report['introduction_pages']<=2
assert 15<=report['main_body_pages']<=25
assert 1<=report['conclusion_pages']<=2
(root/'qa'/'audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
out=root/'qa'/'pages'; out.mkdir(exist_ok=True)
poppler=r'C:\Users\zdeat\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\poppler\Library\bin'
convert_from_path(str(pdf),dpi=100,output_folder=str(out),fmt='png',paths_only=True,output_file='page',thread_count=2,poppler_path=poppler)
print('PNG pages rendered')
