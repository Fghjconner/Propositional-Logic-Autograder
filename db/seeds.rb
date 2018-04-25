# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

questions = [{:text => 'State whether the following is ambiguous or unambiguous, given the parenthesis-dropping conventions.
	P v Q -> R <-> S', :answer => 'unambiguous'},
		{:text => 'State whether the following is ambiguous or unambiguous, given the parenthesis-dropping conventions.
	P -> Q & ~R <-> ~S v T -> U', :answer => 'ambiguous'},
		{:text => 'What sentence would fit the following blank to make the following expression true? P->Q, _ |- Q', :answer => 'P'},
		{:text => 'Complete the following premise so that the sequence is valid. \n PvQ->R, P, ___->S, F |- S', :answer => 'F&R'},
		{:text => 'Complete the following premise so that the sequence is valid. (P & Q)v(___) |- ((P & Q) v R) v S', :answer => 'RvS'},
		{:text => 'Is 431 the best class in the software track?', :answer => 'yes'},
  	 ]

questions.each do |question|
  Question.create!(question)
end