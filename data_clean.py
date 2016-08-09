import xlrd
from lookup_table import LookupTable

# load lookup table
if __name__ == "__main__":
	lookup_book = LookupTable('/Users/brianpan/Desktop/data/lookup_table.xlsx')
	lookup_book.set_sheet_id(1)

	lookup_book.get_basic_info()

	print(lookup_book.set_all_lookup_attributes())
	print(lookup_book.get_lookup_attributes('VDTYPE'))

	# start process
	book = xlrd.open_workbook('/Users/brianpan/Desktop/data/通報表被害人相對人資料.xls')
	sheet = book.sheet_by_index(0)
	print(sheet.nrows, sheet.ncols)
	#
	for idx in range(sheet.ncols):
		attribute = sheet.cell_value(rowx=0,colx=idx)
		print("--- {0}% Start cleaning : {1} ---".format(round((idx/sheet.ncols)*100, 2), attribute))
		if lookup_book.get_lookup_attributes(attribute) is not False:
			print(attribute)	