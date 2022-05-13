print('\timport example')
import example

try:
	s = example.Some()
	print(s.Name())
	print()
	s.ChangeName('new_name')
	print(s.Name())
	print(s.ID())
	print()
	s.ResetID(123)
	print(s.Name())
	print(s.ID())
	print()
	s.SomeChanges(666, "again_new_name")
	print(s.Name())
	print(s.ID())

except Exception as ex:
	print(ex)

