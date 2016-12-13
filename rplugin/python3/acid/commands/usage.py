from acid.commands import BaseCommand
from acid.nvim import current_file, current_path

class Command(BaseCommand):

    name = 'FindUsage'
    cmd_name = 'AcidFindUsage'
    handlers = ['Chain']
    mapping = '<leader>u'
    with_acid = True
    op = "info"


    def configure(self, handler):
        def transform(msg):
            return {
                'op': 'find-symbol',
                'dir': current_path(self.nvim),
                'file': current_file(self.nvim),
                'ns': msg['ns'],
                'name': msg['name'],
                'line': msg.get('line', 1),
                'column': msg.get('column', 1),
                'serialization-format': 'bencode'
            }

        handler.set_transform(transform)
        handler.set_handlers("Proto")

        return handler

    def prepare_payload(self, *args):
        self.nvim.command('normal! "syiw')
        data = self.nvim.funcs.getreg('s')
        ns = path_to_ns(self.nvim)
        return {"symbol": data, "ns": ns}
