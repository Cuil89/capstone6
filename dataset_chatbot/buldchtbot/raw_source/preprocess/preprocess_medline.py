from pathlib import Path
import xml.etree.ElementTree as ET
import json

BASE_DIR = Path(__file__).resolve().parent.parent
OUTPUT_DIR = BASE_DIR / "output"

OUTPUT_DIR.mkdir(exist_ok=True)

xml_file = BASE_DIR / "mplus_topics_2026-06-23.xml"

tree = ET.parse(xml_file)
root = tree.getroot()

knowledge = []

for idx, topic in enumerate(root.findall("health-topic")):

    title = topic.findtext("title", default="")
    summary = topic.findtext("full-summary", default="")
    group = topic.findtext("group-name", default="")

    aliases = []

    alias_node = topic.find("also-called")

    if alias_node is not None:
        aliases = [x.text for x in alias_node.findall("name") if x.text]

    text = f"""
Title:
{title}

Summary:
{summary}

Also Called:
{', '.join(aliases)}

Group:
{group}
"""

    knowledge.append({
        "id": f"medline_{idx}",
        "source": "MedlinePlus",
        "type": "medical_topic",
        "title": title,
        "category": group,
        "text": text.strip()
    })

output = OUTPUT_DIR / "medline.json"

with open(output, "w", encoding="utf-8") as f:
    json.dump(
        knowledge,
        f,
        ensure_ascii=False,
        indent=2
    )

print("="*60)
print("Total Knowledge :", len(knowledge))
print("Saved :", output)