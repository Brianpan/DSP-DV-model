import xlrd
import xlwt
from lookup_table import LookupTable

def step_range(start, end, step):
	while start <= end:
		yield start
		start += step
# load lookup table
if __name__ == "__main__":
	lookup_book = LookupTable('/Users/brianpan/Desktop/data/lookup_table.xlsx')
	lookup_book.set_sheet_id(1)

	lookup_book.get_basic_info()

	print(lookup_book.set_all_lookup_attributes())

	# start process
	book = xlrd.open_workbook('/Users/brianpan/Desktop/data/通報表被害人相對人資料.xls')
	sheet = book.sheet_by_index(0)
	print(sheet.nrows, sheet.ncols)
	#
	output = xlwt.Workbook(encoding="utf-8")
	output_sheet = output.add_sheet("1")
	for idx in range(sheet.ncols):
		attribute = sheet.cell_value(rowx=0,colx=idx)
		print("--- {0}% Start cleaning : {1} ---".format(round((idx/sheet.ncols)*100, 2), attribute))
		if lookup_book.get_lookup_attributes(attribute) is not False:
			print(attribute)
			
			output_sheet.write(0, idx, attribute)
			lookup_attributes = lookup_book.get_lookup_attributes(attribute)
			if attribute == 'HOUSETOWN':
				print(lookup_attributes)
			# lookup loop 
			if attribute == 'MAIMED':
				for ridx in step_range(1, sheet.nrows-1, 1):
					origin_data = sheet.cell_value(rowx=ridx, colx=idx)
					if origin_data != "":
						char_list = list(origin_data.upper())
						try:
							if len(char_list) > 1:
								modify_data = ",".join([lookup_attributes[char_idx] for char_idx in char_list])
							else:
								modify_data = lookup_attributes[char_list[0]]
						except KeyError as e:
							print("cell : {0},{1} failed".format(ridx, idx))
							output_sheet.write(ridx, idx, origin_data)
						else:
							output_sheet.write(ridx, idx, modify_data)
			else:
				
					# print(sheet.cell_value(rowx=1, colx=idx))	
				for ridx in step_range(1, sheet.nrows-1, 1):
					origin_data = sheet.cell_value(rowx=ridx, colx=idx)
					if origin_data is not "":

						try:
							modify_data = lookup_attributes[str(origin_data)]
							
						except KeyError as e:
							# print("cell : {0},{1},{2} failed".format(ridx, idx, origin_data))
							output_sheet.write(ridx, idx, origin_data)
						else:
							output_sheet.write(ridx, idx, modify_data)	
		else:
			for ridx in range(sheet.nrows):
				output_sheet.write(ridx, idx, sheet.cell_value(rowx=ridx, colx=idx))
	

	output.save("/Users/brianpan/Desktop/data/clean_data.xls")	