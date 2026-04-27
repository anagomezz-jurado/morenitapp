enum FilterOperator { contains, equals, greaterThan, lessThan }

class FilterCriterion {
  final String field;
  final String label;
  final FilterOperator operator;
  final dynamic value;
  final String type;

  FilterCriterion({
    required this.field,
    required this.label,
    required this.operator,
    required this.value,
    required this.type,
  });
}