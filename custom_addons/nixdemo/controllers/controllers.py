# -*- coding: utf-8 -*-
# from odoo import http


# class Nixdemo(http.Controller):
#     @http.route('/nixdemo/nixdemo', auth='public')
#     def index(self, **kw):
#         return "Hello, world"

#     @http.route('/nixdemo/nixdemo/objects', auth='public')
#     def list(self, **kw):
#         return http.request.render('nixdemo.listing', {
#             'root': '/nixdemo/nixdemo',
#             'objects': http.request.env['nixdemo.nixdemo'].search([]),
#         })

#     @http.route('/nixdemo/nixdemo/objects/<model("nixdemo.nixdemo"):obj>', auth='public')
#     def object(self, obj, **kw):
#         return http.request.render('nixdemo.object', {
#             'object': obj
#         })

