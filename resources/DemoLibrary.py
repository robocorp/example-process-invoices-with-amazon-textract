from PIL import Image, ImageFont, ImageDraw
import random

invoice_number_area = {
    "width": 0.06253993511199951,
    "height": 0.00984059739857912,
    "left": 0.7599976658821106,
    "top": 0.14011192321777344,
}

image_width = 1264
image_height = 1790
margin_y = 70
box_width = 100


def create_random_image_invoice(original_filepath, font_filepath, filename):
    original_image = Image.open(original_filepath)
    image_editable = ImageDraw.Draw(original_image)
    title_font = ImageFont.truetype(font_filepath, 20)

    text_x = int(invoice_number_area["left"] * image_width)
    text_y = int(invoice_number_area["top"] * image_width) + margin_y
    area_height = int(invoice_number_area["height"] * image_height)
    area_width = int(invoice_number_area["width"] * image_width)
    shape = [
        (text_x, text_y - 2),
        (text_x + area_width + box_width, text_y + area_height + 2),
    ]
    random_invoice_number = random.randint(1000, 9999)
    image_editable.rectangle(shape, fill="white")  # , outline="red")
    image_editable.text(
        (text_x, text_y), f"INV-{random_invoice_number}", (0, 0, 0), font=title_font
    )
    original_image.save(filename)