import xlrd
# row starts from 1
# col starts from 0

def step_range(start, end, step):
	while start <= end:
		yield start
		start += step

class LookupTable(object):
	def __init__(self, data_path):
		self.data_path = data_path
		self.data_book = xlrd.open_workbook(data_path)
		self.attributes = {}
	def set_sheet_id(self, sheet_id):
		self.cur_sheet_id = sheet_id
		self.sheet = self.data_book.sheet_by_index(sheet_id)

	def get_basic_info(self):
		print("sheet rows: {0} ; sheet cols: {1}".format(self.sheet.nrows,
														  self.sheet.ncols))	
	def get_lookup_cell(self, rowx, colx):
		print("{0}".format(self.sheet.cell_value(rowx=rowx, colx=colx)))

	def set_all_lookup_attributes(self):
		for idx in step_range(0, self.sheet.ncols-2, 2):
			self.attributes[self.sheet.cell_value(1, idx)] = idx			
		return self.attributes.keys()

	# return lookup dic	
	def get_lookup_attributes(self, lookup_attribute):
		cidx = self.attributes[lookup_attribute]
		lookup_table = {}
		if cidx is not None:
			ridx = 3
			didx = cidx + 1
			while(True):
				code_val = self.sheet.cell_value(ridx, cidx)
				if code_val is "":
					break
				des_val = self.sheet.cell_value(ridx, didx)
				lookup_table[code_val] = des_val
				ridx += 1
			return lookup_table		
		else:	
			return False
book = LookupTable('/Users/brianpan/Desktop/data/lookup_table.xlsx')
book.set_sheet_id(1)

book.get_basic_info()

print(book.set_all_lookup_attributes())
print(book.get_lookup_attributes('VDTYPE'))