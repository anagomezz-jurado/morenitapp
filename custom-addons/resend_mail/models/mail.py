import requests
from odoo import models

class ResendMail(models.Model):
    _inherit = "mail.mail"

    def send(self, auto_commit=False, raise_exception=False):
        resend_key = "re_MReCWLi9_2oAmxsWkAKFenR172hWB3Usr"

        for mail in self:
            payload = {
                "from": "MorenitApp <no-reply@morenitapp.com>",
                "to": [mail.email_to],
                "subject": mail.subject,
                "html": mail.body_html,
            }

            headers = {
                "Authorization": f"Bearer {resend_key}",
                "Content-Type": "application/json"
            }

            try:
                requests.post(
                    "https://api.resend.com/emails",
                    json=payload,
                    headers=headers,
                    timeout=10
                )
            except Exception as e:
                _logger = self.env['ir.logging']
                _logger.create({
                    'name': 'Resend Error',
                    'type': 'server',
                    'level': 'ERROR',
                    'message': str(e),
                })

        return True