import json


class InvoiceModeler:
    def get_new_invoice(self):
        return {
            "invoice_number": "",
            "order_number": "",
            "invoice_date": "",
            "due_date": "",
            "balance_due": "",
            "from": "",
            "to": "",
        }

    def create_aws_invoice(self, fields):
        invoice = self.get_new_invoice()
        for field in fields:
            key = field.key.text.lower()
            val = field.value.text if field.value else ""

            if "invoice number" in key:
                invoice["invoice_number"] = val
            elif "order number" in key:
                invoice["order_number"] = val
            elif "invoice date" in key:
                invoice["invoice_date"] = val
            elif "due date" in key:
                invoice["due_date"] = val
            elif "balance due" in key or "total due" in key:
                invoice["balance_due"] = val.replace("$", "")
            elif "from:" in key:
                invoice["from"] = val
            elif key in ["bill to:", "to:"]:
                invoice["to"] = val
        return invoice
