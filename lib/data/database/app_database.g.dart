// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FundSourcesTable extends FundSources
    with TableInfo<$FundSourcesTable, FundSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FundSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fundCodeMeta = const VerificationMeta(
    'fundCode',
  );
  @override
  late final GeneratedColumn<String> fundCode = GeneratedColumn<String>(
    'fund_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fundNameMeta = const VerificationMeta(
    'fundName',
  );
  @override
  late final GeneratedColumn<String> fundName = GeneratedColumn<String>(
    'fund_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fundingSourceHeaderMeta =
      const VerificationMeta('fundingSourceHeader');
  @override
  late final GeneratedColumn<String> fundingSourceHeader =
      GeneratedColumn<String>(
        'funding_source_header',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    fundCode,
    fundName,
    fundingSourceHeader,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fund_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<FundSource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fund_code')) {
      context.handle(
        _fundCodeMeta,
        fundCode.isAcceptableOrUnknown(data['fund_code']!, _fundCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_fundCodeMeta);
    }
    if (data.containsKey('fund_name')) {
      context.handle(
        _fundNameMeta,
        fundName.isAcceptableOrUnknown(data['fund_name']!, _fundNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fundNameMeta);
    }
    if (data.containsKey('funding_source_header')) {
      context.handle(
        _fundingSourceHeaderMeta,
        fundingSourceHeader.isAcceptableOrUnknown(
          data['funding_source_header']!,
          _fundingSourceHeaderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fundingSourceHeaderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fundCode};
  @override
  FundSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FundSource(
      fundCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fund_code'],
      )!,
      fundName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fund_name'],
      )!,
      fundingSourceHeader: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}funding_source_header'],
      )!,
    );
  }

  @override
  $FundSourcesTable createAlias(String alias) {
    return $FundSourcesTable(attachedDatabase, alias);
  }
}

class FundSource extends DataClass implements Insertable<FundSource> {
  final String fundCode;
  final String fundName;
  final String fundingSourceHeader;
  const FundSource({
    required this.fundCode,
    required this.fundName,
    required this.fundingSourceHeader,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['fund_code'] = Variable<String>(fundCode);
    map['fund_name'] = Variable<String>(fundName);
    map['funding_source_header'] = Variable<String>(fundingSourceHeader);
    return map;
  }

  FundSourcesCompanion toCompanion(bool nullToAbsent) {
    return FundSourcesCompanion(
      fundCode: Value(fundCode),
      fundName: Value(fundName),
      fundingSourceHeader: Value(fundingSourceHeader),
    );
  }

  factory FundSource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FundSource(
      fundCode: serializer.fromJson<String>(json['fundCode']),
      fundName: serializer.fromJson<String>(json['fundName']),
      fundingSourceHeader: serializer.fromJson<String>(
        json['fundingSourceHeader'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fundCode': serializer.toJson<String>(fundCode),
      'fundName': serializer.toJson<String>(fundName),
      'fundingSourceHeader': serializer.toJson<String>(fundingSourceHeader),
    };
  }

  FundSource copyWith({
    String? fundCode,
    String? fundName,
    String? fundingSourceHeader,
  }) => FundSource(
    fundCode: fundCode ?? this.fundCode,
    fundName: fundName ?? this.fundName,
    fundingSourceHeader: fundingSourceHeader ?? this.fundingSourceHeader,
  );
  FundSource copyWithCompanion(FundSourcesCompanion data) {
    return FundSource(
      fundCode: data.fundCode.present ? data.fundCode.value : this.fundCode,
      fundName: data.fundName.present ? data.fundName.value : this.fundName,
      fundingSourceHeader: data.fundingSourceHeader.present
          ? data.fundingSourceHeader.value
          : this.fundingSourceHeader,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FundSource(')
          ..write('fundCode: $fundCode, ')
          ..write('fundName: $fundName, ')
          ..write('fundingSourceHeader: $fundingSourceHeader')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fundCode, fundName, fundingSourceHeader);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FundSource &&
          other.fundCode == this.fundCode &&
          other.fundName == this.fundName &&
          other.fundingSourceHeader == this.fundingSourceHeader);
}

class FundSourcesCompanion extends UpdateCompanion<FundSource> {
  final Value<String> fundCode;
  final Value<String> fundName;
  final Value<String> fundingSourceHeader;
  final Value<int> rowid;
  const FundSourcesCompanion({
    this.fundCode = const Value.absent(),
    this.fundName = const Value.absent(),
    this.fundingSourceHeader = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FundSourcesCompanion.insert({
    required String fundCode,
    required String fundName,
    required String fundingSourceHeader,
    this.rowid = const Value.absent(),
  }) : fundCode = Value(fundCode),
       fundName = Value(fundName),
       fundingSourceHeader = Value(fundingSourceHeader);
  static Insertable<FundSource> custom({
    Expression<String>? fundCode,
    Expression<String>? fundName,
    Expression<String>? fundingSourceHeader,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fundCode != null) 'fund_code': fundCode,
      if (fundName != null) 'fund_name': fundName,
      if (fundingSourceHeader != null)
        'funding_source_header': fundingSourceHeader,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FundSourcesCompanion copyWith({
    Value<String>? fundCode,
    Value<String>? fundName,
    Value<String>? fundingSourceHeader,
    Value<int>? rowid,
  }) {
    return FundSourcesCompanion(
      fundCode: fundCode ?? this.fundCode,
      fundName: fundName ?? this.fundName,
      fundingSourceHeader: fundingSourceHeader ?? this.fundingSourceHeader,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fundCode.present) {
      map['fund_code'] = Variable<String>(fundCode.value);
    }
    if (fundName.present) {
      map['fund_name'] = Variable<String>(fundName.value);
    }
    if (fundingSourceHeader.present) {
      map['funding_source_header'] = Variable<String>(
        fundingSourceHeader.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FundSourcesCompanion(')
          ..write('fundCode: $fundCode, ')
          ..write('fundName: $fundName, ')
          ..write('fundingSourceHeader: $fundingSourceHeader, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UacsCodesTable extends UacsCodes
    with TableInfo<$UacsCodesTable, UacsCode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UacsCodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountCodeMeta = const VerificationMeta(
    'accountCode',
  );
  @override
  late final GeneratedColumn<String> accountCode = GeneratedColumn<String>(
    'account_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _objectTitleMeta = const VerificationMeta(
    'objectTitle',
  );
  @override
  late final GeneratedColumn<String> objectTitle = GeneratedColumn<String>(
    'object_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allotmentClassMeta = const VerificationMeta(
    'allotmentClass',
  );
  @override
  late final GeneratedColumn<String> allotmentClass = GeneratedColumn<String>(
    'allotment_class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountCode,
    objectTitle,
    allotmentClass,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'uacs_codes';
  @override
  VerificationContext validateIntegrity(
    Insertable<UacsCode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_code')) {
      context.handle(
        _accountCodeMeta,
        accountCode.isAcceptableOrUnknown(
          data['account_code']!,
          _accountCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountCodeMeta);
    }
    if (data.containsKey('object_title')) {
      context.handle(
        _objectTitleMeta,
        objectTitle.isAcceptableOrUnknown(
          data['object_title']!,
          _objectTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_objectTitleMeta);
    }
    if (data.containsKey('allotment_class')) {
      context.handle(
        _allotmentClassMeta,
        allotmentClass.isAcceptableOrUnknown(
          data['allotment_class']!,
          _allotmentClassMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allotmentClassMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountCode};
  @override
  UacsCode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UacsCode(
      accountCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_code'],
      )!,
      objectTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object_title'],
      )!,
      allotmentClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allotment_class'],
      )!,
    );
  }

  @override
  $UacsCodesTable createAlias(String alias) {
    return $UacsCodesTable(attachedDatabase, alias);
  }
}

class UacsCode extends DataClass implements Insertable<UacsCode> {
  final String accountCode;
  final String objectTitle;
  final String allotmentClass;
  const UacsCode({
    required this.accountCode,
    required this.objectTitle,
    required this.allotmentClass,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_code'] = Variable<String>(accountCode);
    map['object_title'] = Variable<String>(objectTitle);
    map['allotment_class'] = Variable<String>(allotmentClass);
    return map;
  }

  UacsCodesCompanion toCompanion(bool nullToAbsent) {
    return UacsCodesCompanion(
      accountCode: Value(accountCode),
      objectTitle: Value(objectTitle),
      allotmentClass: Value(allotmentClass),
    );
  }

  factory UacsCode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UacsCode(
      accountCode: serializer.fromJson<String>(json['accountCode']),
      objectTitle: serializer.fromJson<String>(json['objectTitle']),
      allotmentClass: serializer.fromJson<String>(json['allotmentClass']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountCode': serializer.toJson<String>(accountCode),
      'objectTitle': serializer.toJson<String>(objectTitle),
      'allotmentClass': serializer.toJson<String>(allotmentClass),
    };
  }

  UacsCode copyWith({
    String? accountCode,
    String? objectTitle,
    String? allotmentClass,
  }) => UacsCode(
    accountCode: accountCode ?? this.accountCode,
    objectTitle: objectTitle ?? this.objectTitle,
    allotmentClass: allotmentClass ?? this.allotmentClass,
  );
  UacsCode copyWithCompanion(UacsCodesCompanion data) {
    return UacsCode(
      accountCode: data.accountCode.present
          ? data.accountCode.value
          : this.accountCode,
      objectTitle: data.objectTitle.present
          ? data.objectTitle.value
          : this.objectTitle,
      allotmentClass: data.allotmentClass.present
          ? data.allotmentClass.value
          : this.allotmentClass,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UacsCode(')
          ..write('accountCode: $accountCode, ')
          ..write('objectTitle: $objectTitle, ')
          ..write('allotmentClass: $allotmentClass')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountCode, objectTitle, allotmentClass);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UacsCode &&
          other.accountCode == this.accountCode &&
          other.objectTitle == this.objectTitle &&
          other.allotmentClass == this.allotmentClass);
}

class UacsCodesCompanion extends UpdateCompanion<UacsCode> {
  final Value<String> accountCode;
  final Value<String> objectTitle;
  final Value<String> allotmentClass;
  final Value<int> rowid;
  const UacsCodesCompanion({
    this.accountCode = const Value.absent(),
    this.objectTitle = const Value.absent(),
    this.allotmentClass = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UacsCodesCompanion.insert({
    required String accountCode,
    required String objectTitle,
    required String allotmentClass,
    this.rowid = const Value.absent(),
  }) : accountCode = Value(accountCode),
       objectTitle = Value(objectTitle),
       allotmentClass = Value(allotmentClass);
  static Insertable<UacsCode> custom({
    Expression<String>? accountCode,
    Expression<String>? objectTitle,
    Expression<String>? allotmentClass,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountCode != null) 'account_code': accountCode,
      if (objectTitle != null) 'object_title': objectTitle,
      if (allotmentClass != null) 'allotment_class': allotmentClass,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UacsCodesCompanion copyWith({
    Value<String>? accountCode,
    Value<String>? objectTitle,
    Value<String>? allotmentClass,
    Value<int>? rowid,
  }) {
    return UacsCodesCompanion(
      accountCode: accountCode ?? this.accountCode,
      objectTitle: objectTitle ?? this.objectTitle,
      allotmentClass: allotmentClass ?? this.allotmentClass,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountCode.present) {
      map['account_code'] = Variable<String>(accountCode.value);
    }
    if (objectTitle.present) {
      map['object_title'] = Variable<String>(objectTitle.value);
    }
    if (allotmentClass.present) {
      map['allotment_class'] = Variable<String>(allotmentClass.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UacsCodesCompanion(')
          ..write('accountCode: $accountCode, ')
          ..write('objectTitle: $objectTitle, ')
          ..write('allotmentClass: $allotmentClass, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetAllocationsTable extends BudgetAllocations
    with TableInfo<$BudgetAllocationsTable, BudgetAllocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetAllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fiscalYearMeta = const VerificationMeta(
    'fiscalYear',
  );
  @override
  late final GeneratedColumn<String> fiscalYear = GeneratedColumn<String>(
    'fiscal_year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fundCodeMeta = const VerificationMeta(
    'fundCode',
  );
  @override
  late final GeneratedColumn<String> fundCode = GeneratedColumn<String>(
    'fund_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fund_sources (fund_code)',
    ),
  );
  static const VerificationMeta _allotmentClassMeta = const VerificationMeta(
    'allotmentClass',
  );
  @override
  late final GeneratedColumn<String> allotmentClass = GeneratedColumn<String>(
    'allotment_class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountCodeMeta = const VerificationMeta(
    'accountCode',
  );
  @override
  late final GeneratedColumn<String> accountCode = GeneratedColumn<String>(
    'account_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES uacs_codes (account_code)',
    ),
  );
  static const VerificationMeta _authorizedAppropriationsMeta =
      const VerificationMeta('authorizedAppropriations');
  @override
  late final GeneratedColumn<double> authorizedAppropriations =
      GeneratedColumn<double>(
        'authorized_appropriations',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _adjustmentsAppropriationsMeta =
      const VerificationMeta('adjustmentsAppropriations');
  @override
  late final GeneratedColumn<double> adjustmentsAppropriations =
      GeneratedColumn<double>(
        'adjustments_appropriations',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _allotmentReceivedMeta = const VerificationMeta(
    'allotmentReceived',
  );
  @override
  late final GeneratedColumn<double> allotmentReceived =
      GeneratedColumn<double>(
        'allotment_received',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _adjustmentsAllotmentMeta =
      const VerificationMeta('adjustmentsAllotment');
  @override
  late final GeneratedColumn<double> adjustmentsAllotment =
      GeneratedColumn<double>(
        'adjustments_allotment',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _dateOfAllocationMeta = const VerificationMeta(
    'dateOfAllocation',
  );
  @override
  late final GeneratedColumn<String> dateOfAllocation = GeneratedColumn<String>(
    'date_of_allocation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<int> isHidden = GeneratedColumn<int>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fiscalYear,
    fundCode,
    allotmentClass,
    accountCode,
    authorizedAppropriations,
    adjustmentsAppropriations,
    allotmentReceived,
    adjustmentsAllotment,
    dateOfAllocation,
    isHidden,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetAllocation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fiscal_year')) {
      context.handle(
        _fiscalYearMeta,
        fiscalYear.isAcceptableOrUnknown(data['fiscal_year']!, _fiscalYearMeta),
      );
    } else if (isInserting) {
      context.missing(_fiscalYearMeta);
    }
    if (data.containsKey('fund_code')) {
      context.handle(
        _fundCodeMeta,
        fundCode.isAcceptableOrUnknown(data['fund_code']!, _fundCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_fundCodeMeta);
    }
    if (data.containsKey('allotment_class')) {
      context.handle(
        _allotmentClassMeta,
        allotmentClass.isAcceptableOrUnknown(
          data['allotment_class']!,
          _allotmentClassMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allotmentClassMeta);
    }
    if (data.containsKey('account_code')) {
      context.handle(
        _accountCodeMeta,
        accountCode.isAcceptableOrUnknown(
          data['account_code']!,
          _accountCodeMeta,
        ),
      );
    }
    if (data.containsKey('authorized_appropriations')) {
      context.handle(
        _authorizedAppropriationsMeta,
        authorizedAppropriations.isAcceptableOrUnknown(
          data['authorized_appropriations']!,
          _authorizedAppropriationsMeta,
        ),
      );
    }
    if (data.containsKey('adjustments_appropriations')) {
      context.handle(
        _adjustmentsAppropriationsMeta,
        adjustmentsAppropriations.isAcceptableOrUnknown(
          data['adjustments_appropriations']!,
          _adjustmentsAppropriationsMeta,
        ),
      );
    }
    if (data.containsKey('allotment_received')) {
      context.handle(
        _allotmentReceivedMeta,
        allotmentReceived.isAcceptableOrUnknown(
          data['allotment_received']!,
          _allotmentReceivedMeta,
        ),
      );
    }
    if (data.containsKey('adjustments_allotment')) {
      context.handle(
        _adjustmentsAllotmentMeta,
        adjustmentsAllotment.isAcceptableOrUnknown(
          data['adjustments_allotment']!,
          _adjustmentsAllotmentMeta,
        ),
      );
    }
    if (data.containsKey('date_of_allocation')) {
      context.handle(
        _dateOfAllocationMeta,
        dateOfAllocation.isAcceptableOrUnknown(
          data['date_of_allocation']!,
          _dateOfAllocationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateOfAllocationMeta);
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetAllocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetAllocation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fiscalYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fiscal_year'],
      )!,
      fundCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fund_code'],
      )!,
      allotmentClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allotment_class'],
      )!,
      accountCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_code'],
      ),
      authorizedAppropriations: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}authorized_appropriations'],
      )!,
      adjustmentsAppropriations: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}adjustments_appropriations'],
      )!,
      allotmentReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}allotment_received'],
      )!,
      adjustmentsAllotment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}adjustments_allotment'],
      )!,
      dateOfAllocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_of_allocation'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_hidden'],
      )!,
    );
  }

  @override
  $BudgetAllocationsTable createAlias(String alias) {
    return $BudgetAllocationsTable(attachedDatabase, alias);
  }
}

class BudgetAllocation extends DataClass
    implements Insertable<BudgetAllocation> {
  final int id;
  final String fiscalYear;
  final String fundCode;
  final String allotmentClass;
  final String? accountCode;
  final double authorizedAppropriations;
  final double adjustmentsAppropriations;
  final double allotmentReceived;
  final double adjustmentsAllotment;
  final String dateOfAllocation;
  final int isHidden;
  const BudgetAllocation({
    required this.id,
    required this.fiscalYear,
    required this.fundCode,
    required this.allotmentClass,
    this.accountCode,
    required this.authorizedAppropriations,
    required this.adjustmentsAppropriations,
    required this.allotmentReceived,
    required this.adjustmentsAllotment,
    required this.dateOfAllocation,
    required this.isHidden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fiscal_year'] = Variable<String>(fiscalYear);
    map['fund_code'] = Variable<String>(fundCode);
    map['allotment_class'] = Variable<String>(allotmentClass);
    if (!nullToAbsent || accountCode != null) {
      map['account_code'] = Variable<String>(accountCode);
    }
    map['authorized_appropriations'] = Variable<double>(
      authorizedAppropriations,
    );
    map['adjustments_appropriations'] = Variable<double>(
      adjustmentsAppropriations,
    );
    map['allotment_received'] = Variable<double>(allotmentReceived);
    map['adjustments_allotment'] = Variable<double>(adjustmentsAllotment);
    map['date_of_allocation'] = Variable<String>(dateOfAllocation);
    map['is_hidden'] = Variable<int>(isHidden);
    return map;
  }

  BudgetAllocationsCompanion toCompanion(bool nullToAbsent) {
    return BudgetAllocationsCompanion(
      id: Value(id),
      fiscalYear: Value(fiscalYear),
      fundCode: Value(fundCode),
      allotmentClass: Value(allotmentClass),
      accountCode: accountCode == null && nullToAbsent
          ? const Value.absent()
          : Value(accountCode),
      authorizedAppropriations: Value(authorizedAppropriations),
      adjustmentsAppropriations: Value(adjustmentsAppropriations),
      allotmentReceived: Value(allotmentReceived),
      adjustmentsAllotment: Value(adjustmentsAllotment),
      dateOfAllocation: Value(dateOfAllocation),
      isHidden: Value(isHidden),
    );
  }

  factory BudgetAllocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetAllocation(
      id: serializer.fromJson<int>(json['id']),
      fiscalYear: serializer.fromJson<String>(json['fiscalYear']),
      fundCode: serializer.fromJson<String>(json['fundCode']),
      allotmentClass: serializer.fromJson<String>(json['allotmentClass']),
      accountCode: serializer.fromJson<String?>(json['accountCode']),
      authorizedAppropriations: serializer.fromJson<double>(
        json['authorizedAppropriations'],
      ),
      adjustmentsAppropriations: serializer.fromJson<double>(
        json['adjustmentsAppropriations'],
      ),
      allotmentReceived: serializer.fromJson<double>(json['allotmentReceived']),
      adjustmentsAllotment: serializer.fromJson<double>(
        json['adjustmentsAllotment'],
      ),
      dateOfAllocation: serializer.fromJson<String>(json['dateOfAllocation']),
      isHidden: serializer.fromJson<int>(json['isHidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fiscalYear': serializer.toJson<String>(fiscalYear),
      'fundCode': serializer.toJson<String>(fundCode),
      'allotmentClass': serializer.toJson<String>(allotmentClass),
      'accountCode': serializer.toJson<String?>(accountCode),
      'authorizedAppropriations': serializer.toJson<double>(
        authorizedAppropriations,
      ),
      'adjustmentsAppropriations': serializer.toJson<double>(
        adjustmentsAppropriations,
      ),
      'allotmentReceived': serializer.toJson<double>(allotmentReceived),
      'adjustmentsAllotment': serializer.toJson<double>(adjustmentsAllotment),
      'dateOfAllocation': serializer.toJson<String>(dateOfAllocation),
      'isHidden': serializer.toJson<int>(isHidden),
    };
  }

  BudgetAllocation copyWith({
    int? id,
    String? fiscalYear,
    String? fundCode,
    String? allotmentClass,
    Value<String?> accountCode = const Value.absent(),
    double? authorizedAppropriations,
    double? adjustmentsAppropriations,
    double? allotmentReceived,
    double? adjustmentsAllotment,
    String? dateOfAllocation,
    int? isHidden,
  }) => BudgetAllocation(
    id: id ?? this.id,
    fiscalYear: fiscalYear ?? this.fiscalYear,
    fundCode: fundCode ?? this.fundCode,
    allotmentClass: allotmentClass ?? this.allotmentClass,
    accountCode: accountCode.present ? accountCode.value : this.accountCode,
    authorizedAppropriations:
        authorizedAppropriations ?? this.authorizedAppropriations,
    adjustmentsAppropriations:
        adjustmentsAppropriations ?? this.adjustmentsAppropriations,
    allotmentReceived: allotmentReceived ?? this.allotmentReceived,
    adjustmentsAllotment: adjustmentsAllotment ?? this.adjustmentsAllotment,
    dateOfAllocation: dateOfAllocation ?? this.dateOfAllocation,
    isHidden: isHidden ?? this.isHidden,
  );
  BudgetAllocation copyWithCompanion(BudgetAllocationsCompanion data) {
    return BudgetAllocation(
      id: data.id.present ? data.id.value : this.id,
      fiscalYear: data.fiscalYear.present
          ? data.fiscalYear.value
          : this.fiscalYear,
      fundCode: data.fundCode.present ? data.fundCode.value : this.fundCode,
      allotmentClass: data.allotmentClass.present
          ? data.allotmentClass.value
          : this.allotmentClass,
      accountCode: data.accountCode.present
          ? data.accountCode.value
          : this.accountCode,
      authorizedAppropriations: data.authorizedAppropriations.present
          ? data.authorizedAppropriations.value
          : this.authorizedAppropriations,
      adjustmentsAppropriations: data.adjustmentsAppropriations.present
          ? data.adjustmentsAppropriations.value
          : this.adjustmentsAppropriations,
      allotmentReceived: data.allotmentReceived.present
          ? data.allotmentReceived.value
          : this.allotmentReceived,
      adjustmentsAllotment: data.adjustmentsAllotment.present
          ? data.adjustmentsAllotment.value
          : this.adjustmentsAllotment,
      dateOfAllocation: data.dateOfAllocation.present
          ? data.dateOfAllocation.value
          : this.dateOfAllocation,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetAllocation(')
          ..write('id: $id, ')
          ..write('fiscalYear: $fiscalYear, ')
          ..write('fundCode: $fundCode, ')
          ..write('allotmentClass: $allotmentClass, ')
          ..write('accountCode: $accountCode, ')
          ..write('authorizedAppropriations: $authorizedAppropriations, ')
          ..write('adjustmentsAppropriations: $adjustmentsAppropriations, ')
          ..write('allotmentReceived: $allotmentReceived, ')
          ..write('adjustmentsAllotment: $adjustmentsAllotment, ')
          ..write('dateOfAllocation: $dateOfAllocation, ')
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fiscalYear,
    fundCode,
    allotmentClass,
    accountCode,
    authorizedAppropriations,
    adjustmentsAppropriations,
    allotmentReceived,
    adjustmentsAllotment,
    dateOfAllocation,
    isHidden,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetAllocation &&
          other.id == this.id &&
          other.fiscalYear == this.fiscalYear &&
          other.fundCode == this.fundCode &&
          other.allotmentClass == this.allotmentClass &&
          other.accountCode == this.accountCode &&
          other.authorizedAppropriations == this.authorizedAppropriations &&
          other.adjustmentsAppropriations == this.adjustmentsAppropriations &&
          other.allotmentReceived == this.allotmentReceived &&
          other.adjustmentsAllotment == this.adjustmentsAllotment &&
          other.dateOfAllocation == this.dateOfAllocation &&
          other.isHidden == this.isHidden);
}

class BudgetAllocationsCompanion extends UpdateCompanion<BudgetAllocation> {
  final Value<int> id;
  final Value<String> fiscalYear;
  final Value<String> fundCode;
  final Value<String> allotmentClass;
  final Value<String?> accountCode;
  final Value<double> authorizedAppropriations;
  final Value<double> adjustmentsAppropriations;
  final Value<double> allotmentReceived;
  final Value<double> adjustmentsAllotment;
  final Value<String> dateOfAllocation;
  final Value<int> isHidden;
  const BudgetAllocationsCompanion({
    this.id = const Value.absent(),
    this.fiscalYear = const Value.absent(),
    this.fundCode = const Value.absent(),
    this.allotmentClass = const Value.absent(),
    this.accountCode = const Value.absent(),
    this.authorizedAppropriations = const Value.absent(),
    this.adjustmentsAppropriations = const Value.absent(),
    this.allotmentReceived = const Value.absent(),
    this.adjustmentsAllotment = const Value.absent(),
    this.dateOfAllocation = const Value.absent(),
    this.isHidden = const Value.absent(),
  });
  BudgetAllocationsCompanion.insert({
    this.id = const Value.absent(),
    required String fiscalYear,
    required String fundCode,
    required String allotmentClass,
    this.accountCode = const Value.absent(),
    this.authorizedAppropriations = const Value.absent(),
    this.adjustmentsAppropriations = const Value.absent(),
    this.allotmentReceived = const Value.absent(),
    this.adjustmentsAllotment = const Value.absent(),
    required String dateOfAllocation,
    this.isHidden = const Value.absent(),
  }) : fiscalYear = Value(fiscalYear),
       fundCode = Value(fundCode),
       allotmentClass = Value(allotmentClass),
       dateOfAllocation = Value(dateOfAllocation);
  static Insertable<BudgetAllocation> custom({
    Expression<int>? id,
    Expression<String>? fiscalYear,
    Expression<String>? fundCode,
    Expression<String>? allotmentClass,
    Expression<String>? accountCode,
    Expression<double>? authorizedAppropriations,
    Expression<double>? adjustmentsAppropriations,
    Expression<double>? allotmentReceived,
    Expression<double>? adjustmentsAllotment,
    Expression<String>? dateOfAllocation,
    Expression<int>? isHidden,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fiscalYear != null) 'fiscal_year': fiscalYear,
      if (fundCode != null) 'fund_code': fundCode,
      if (allotmentClass != null) 'allotment_class': allotmentClass,
      if (accountCode != null) 'account_code': accountCode,
      if (authorizedAppropriations != null)
        'authorized_appropriations': authorizedAppropriations,
      if (adjustmentsAppropriations != null)
        'adjustments_appropriations': adjustmentsAppropriations,
      if (allotmentReceived != null) 'allotment_received': allotmentReceived,
      if (adjustmentsAllotment != null)
        'adjustments_allotment': adjustmentsAllotment,
      if (dateOfAllocation != null) 'date_of_allocation': dateOfAllocation,
      if (isHidden != null) 'is_hidden': isHidden,
    });
  }

  BudgetAllocationsCompanion copyWith({
    Value<int>? id,
    Value<String>? fiscalYear,
    Value<String>? fundCode,
    Value<String>? allotmentClass,
    Value<String?>? accountCode,
    Value<double>? authorizedAppropriations,
    Value<double>? adjustmentsAppropriations,
    Value<double>? allotmentReceived,
    Value<double>? adjustmentsAllotment,
    Value<String>? dateOfAllocation,
    Value<int>? isHidden,
  }) {
    return BudgetAllocationsCompanion(
      id: id ?? this.id,
      fiscalYear: fiscalYear ?? this.fiscalYear,
      fundCode: fundCode ?? this.fundCode,
      allotmentClass: allotmentClass ?? this.allotmentClass,
      accountCode: accountCode ?? this.accountCode,
      authorizedAppropriations:
          authorizedAppropriations ?? this.authorizedAppropriations,
      adjustmentsAppropriations:
          adjustmentsAppropriations ?? this.adjustmentsAppropriations,
      allotmentReceived: allotmentReceived ?? this.allotmentReceived,
      adjustmentsAllotment: adjustmentsAllotment ?? this.adjustmentsAllotment,
      dateOfAllocation: dateOfAllocation ?? this.dateOfAllocation,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fiscalYear.present) {
      map['fiscal_year'] = Variable<String>(fiscalYear.value);
    }
    if (fundCode.present) {
      map['fund_code'] = Variable<String>(fundCode.value);
    }
    if (allotmentClass.present) {
      map['allotment_class'] = Variable<String>(allotmentClass.value);
    }
    if (accountCode.present) {
      map['account_code'] = Variable<String>(accountCode.value);
    }
    if (authorizedAppropriations.present) {
      map['authorized_appropriations'] = Variable<double>(
        authorizedAppropriations.value,
      );
    }
    if (adjustmentsAppropriations.present) {
      map['adjustments_appropriations'] = Variable<double>(
        adjustmentsAppropriations.value,
      );
    }
    if (allotmentReceived.present) {
      map['allotment_received'] = Variable<double>(allotmentReceived.value);
    }
    if (adjustmentsAllotment.present) {
      map['adjustments_allotment'] = Variable<double>(
        adjustmentsAllotment.value,
      );
    }
    if (dateOfAllocation.present) {
      map['date_of_allocation'] = Variable<String>(dateOfAllocation.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<int>(isHidden.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetAllocationsCompanion(')
          ..write('id: $id, ')
          ..write('fiscalYear: $fiscalYear, ')
          ..write('fundCode: $fundCode, ')
          ..write('allotmentClass: $allotmentClass, ')
          ..write('accountCode: $accountCode, ')
          ..write('authorizedAppropriations: $authorizedAppropriations, ')
          ..write('adjustmentsAppropriations: $adjustmentsAppropriations, ')
          ..write('allotmentReceived: $allotmentReceived, ')
          ..write('adjustmentsAllotment: $adjustmentsAllotment, ')
          ..write('dateOfAllocation: $dateOfAllocation, ')
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }
}

class $ObligationRegistriesTable extends ObligationRegistries
    with TableInfo<$ObligationRegistriesTable, ObligationRegistry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObligationRegistriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _obrNoMeta = const VerificationMeta('obrNo');
  @override
  late final GeneratedColumn<String> obrNo = GeneratedColumn<String>(
    'obr_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fundCodeMeta = const VerificationMeta(
    'fundCode',
  );
  @override
  late final GeneratedColumn<String> fundCode = GeneratedColumn<String>(
    'fund_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fund_sources (fund_code)',
    ),
  );
  static const VerificationMeta _accountCodeMeta = const VerificationMeta(
    'accountCode',
  );
  @override
  late final GeneratedColumn<String> accountCode = GeneratedColumn<String>(
    'account_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES uacs_codes (account_code)',
    ),
  );
  static const VerificationMeta _allotmentClassificationMeta =
      const VerificationMeta('allotmentClassification');
  @override
  late final GeneratedColumn<String> allotmentClassification =
      GeneratedColumn<String>(
        'allotment_classification',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _payeeMeta = const VerificationMeta('payee');
  @override
  late final GeneratedColumn<String> payee = GeneratedColumn<String>(
    'payee',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _particularMeta = const VerificationMeta(
    'particular',
  );
  @override
  late final GeneratedColumn<String> particular = GeneratedColumn<String>(
    'particular',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grossAmountMeta = const VerificationMeta(
    'grossAmount',
  );
  @override
  late final GeneratedColumn<double> grossAmount = GeneratedColumn<double>(
    'gross_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _disbursementAmountMeta =
      const VerificationMeta('disbursementAmount');
  @override
  late final GeneratedColumn<double> disbursementAmount =
      GeneratedColumn<double>(
        'disbursement_amount',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _attachmentFilenameMeta =
      const VerificationMeta('attachmentFilename');
  @override
  late final GeneratedColumn<String> attachmentFilename =
      GeneratedColumn<String>(
        'attachment_filename',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _attachmentLocalPathMeta =
      const VerificationMeta('attachmentLocalPath');
  @override
  late final GeneratedColumn<String> attachmentLocalPath =
      GeneratedColumn<String>(
        'attachment_local_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    obrNo,
    date,
    fundCode,
    accountCode,
    allotmentClassification,
    payee,
    particular,
    description,
    grossAmount,
    disbursementAmount,
    attachmentFilename,
    attachmentLocalPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'obligation_registries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObligationRegistry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('obr_no')) {
      context.handle(
        _obrNoMeta,
        obrNo.isAcceptableOrUnknown(data['obr_no']!, _obrNoMeta),
      );
    } else if (isInserting) {
      context.missing(_obrNoMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('fund_code')) {
      context.handle(
        _fundCodeMeta,
        fundCode.isAcceptableOrUnknown(data['fund_code']!, _fundCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_fundCodeMeta);
    }
    if (data.containsKey('account_code')) {
      context.handle(
        _accountCodeMeta,
        accountCode.isAcceptableOrUnknown(
          data['account_code']!,
          _accountCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountCodeMeta);
    }
    if (data.containsKey('allotment_classification')) {
      context.handle(
        _allotmentClassificationMeta,
        allotmentClassification.isAcceptableOrUnknown(
          data['allotment_classification']!,
          _allotmentClassificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allotmentClassificationMeta);
    }
    if (data.containsKey('payee')) {
      context.handle(
        _payeeMeta,
        payee.isAcceptableOrUnknown(data['payee']!, _payeeMeta),
      );
    } else if (isInserting) {
      context.missing(_payeeMeta);
    }
    if (data.containsKey('particular')) {
      context.handle(
        _particularMeta,
        particular.isAcceptableOrUnknown(data['particular']!, _particularMeta),
      );
    } else if (isInserting) {
      context.missing(_particularMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('gross_amount')) {
      context.handle(
        _grossAmountMeta,
        grossAmount.isAcceptableOrUnknown(
          data['gross_amount']!,
          _grossAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grossAmountMeta);
    }
    if (data.containsKey('disbursement_amount')) {
      context.handle(
        _disbursementAmountMeta,
        disbursementAmount.isAcceptableOrUnknown(
          data['disbursement_amount']!,
          _disbursementAmountMeta,
        ),
      );
    }
    if (data.containsKey('attachment_filename')) {
      context.handle(
        _attachmentFilenameMeta,
        attachmentFilename.isAcceptableOrUnknown(
          data['attachment_filename']!,
          _attachmentFilenameMeta,
        ),
      );
    }
    if (data.containsKey('attachment_local_path')) {
      context.handle(
        _attachmentLocalPathMeta,
        attachmentLocalPath.isAcceptableOrUnknown(
          data['attachment_local_path']!,
          _attachmentLocalPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ObligationRegistry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObligationRegistry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      obrNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}obr_no'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      fundCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fund_code'],
      )!,
      accountCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_code'],
      )!,
      allotmentClassification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allotment_classification'],
      )!,
      payee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payee'],
      )!,
      particular: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}particular'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      grossAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gross_amount'],
      )!,
      disbursementAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}disbursement_amount'],
      )!,
      attachmentFilename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_filename'],
      ),
      attachmentLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_local_path'],
      ),
    );
  }

  @override
  $ObligationRegistriesTable createAlias(String alias) {
    return $ObligationRegistriesTable(attachedDatabase, alias);
  }
}

class ObligationRegistry extends DataClass
    implements Insertable<ObligationRegistry> {
  final int id;
  final String obrNo;
  final String date;
  final String fundCode;
  final String accountCode;
  final String allotmentClassification;
  final String payee;
  final String particular;
  final String? description;
  final double grossAmount;
  final double disbursementAmount;
  final String? attachmentFilename;
  final String? attachmentLocalPath;
  const ObligationRegistry({
    required this.id,
    required this.obrNo,
    required this.date,
    required this.fundCode,
    required this.accountCode,
    required this.allotmentClassification,
    required this.payee,
    required this.particular,
    this.description,
    required this.grossAmount,
    required this.disbursementAmount,
    this.attachmentFilename,
    this.attachmentLocalPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['obr_no'] = Variable<String>(obrNo);
    map['date'] = Variable<String>(date);
    map['fund_code'] = Variable<String>(fundCode);
    map['account_code'] = Variable<String>(accountCode);
    map['allotment_classification'] = Variable<String>(allotmentClassification);
    map['payee'] = Variable<String>(payee);
    map['particular'] = Variable<String>(particular);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['gross_amount'] = Variable<double>(grossAmount);
    map['disbursement_amount'] = Variable<double>(disbursementAmount);
    if (!nullToAbsent || attachmentFilename != null) {
      map['attachment_filename'] = Variable<String>(attachmentFilename);
    }
    if (!nullToAbsent || attachmentLocalPath != null) {
      map['attachment_local_path'] = Variable<String>(attachmentLocalPath);
    }
    return map;
  }

  ObligationRegistriesCompanion toCompanion(bool nullToAbsent) {
    return ObligationRegistriesCompanion(
      id: Value(id),
      obrNo: Value(obrNo),
      date: Value(date),
      fundCode: Value(fundCode),
      accountCode: Value(accountCode),
      allotmentClassification: Value(allotmentClassification),
      payee: Value(payee),
      particular: Value(particular),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      grossAmount: Value(grossAmount),
      disbursementAmount: Value(disbursementAmount),
      attachmentFilename: attachmentFilename == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentFilename),
      attachmentLocalPath: attachmentLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentLocalPath),
    );
  }

  factory ObligationRegistry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObligationRegistry(
      id: serializer.fromJson<int>(json['id']),
      obrNo: serializer.fromJson<String>(json['obrNo']),
      date: serializer.fromJson<String>(json['date']),
      fundCode: serializer.fromJson<String>(json['fundCode']),
      accountCode: serializer.fromJson<String>(json['accountCode']),
      allotmentClassification: serializer.fromJson<String>(
        json['allotmentClassification'],
      ),
      payee: serializer.fromJson<String>(json['payee']),
      particular: serializer.fromJson<String>(json['particular']),
      description: serializer.fromJson<String?>(json['description']),
      grossAmount: serializer.fromJson<double>(json['grossAmount']),
      disbursementAmount: serializer.fromJson<double>(
        json['disbursementAmount'],
      ),
      attachmentFilename: serializer.fromJson<String?>(
        json['attachmentFilename'],
      ),
      attachmentLocalPath: serializer.fromJson<String?>(
        json['attachmentLocalPath'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'obrNo': serializer.toJson<String>(obrNo),
      'date': serializer.toJson<String>(date),
      'fundCode': serializer.toJson<String>(fundCode),
      'accountCode': serializer.toJson<String>(accountCode),
      'allotmentClassification': serializer.toJson<String>(
        allotmentClassification,
      ),
      'payee': serializer.toJson<String>(payee),
      'particular': serializer.toJson<String>(particular),
      'description': serializer.toJson<String?>(description),
      'grossAmount': serializer.toJson<double>(grossAmount),
      'disbursementAmount': serializer.toJson<double>(disbursementAmount),
      'attachmentFilename': serializer.toJson<String?>(attachmentFilename),
      'attachmentLocalPath': serializer.toJson<String?>(attachmentLocalPath),
    };
  }

  ObligationRegistry copyWith({
    int? id,
    String? obrNo,
    String? date,
    String? fundCode,
    String? accountCode,
    String? allotmentClassification,
    String? payee,
    String? particular,
    Value<String?> description = const Value.absent(),
    double? grossAmount,
    double? disbursementAmount,
    Value<String?> attachmentFilename = const Value.absent(),
    Value<String?> attachmentLocalPath = const Value.absent(),
  }) => ObligationRegistry(
    id: id ?? this.id,
    obrNo: obrNo ?? this.obrNo,
    date: date ?? this.date,
    fundCode: fundCode ?? this.fundCode,
    accountCode: accountCode ?? this.accountCode,
    allotmentClassification:
        allotmentClassification ?? this.allotmentClassification,
    payee: payee ?? this.payee,
    particular: particular ?? this.particular,
    description: description.present ? description.value : this.description,
    grossAmount: grossAmount ?? this.grossAmount,
    disbursementAmount: disbursementAmount ?? this.disbursementAmount,
    attachmentFilename: attachmentFilename.present
        ? attachmentFilename.value
        : this.attachmentFilename,
    attachmentLocalPath: attachmentLocalPath.present
        ? attachmentLocalPath.value
        : this.attachmentLocalPath,
  );
  ObligationRegistry copyWithCompanion(ObligationRegistriesCompanion data) {
    return ObligationRegistry(
      id: data.id.present ? data.id.value : this.id,
      obrNo: data.obrNo.present ? data.obrNo.value : this.obrNo,
      date: data.date.present ? data.date.value : this.date,
      fundCode: data.fundCode.present ? data.fundCode.value : this.fundCode,
      accountCode: data.accountCode.present
          ? data.accountCode.value
          : this.accountCode,
      allotmentClassification: data.allotmentClassification.present
          ? data.allotmentClassification.value
          : this.allotmentClassification,
      payee: data.payee.present ? data.payee.value : this.payee,
      particular: data.particular.present
          ? data.particular.value
          : this.particular,
      description: data.description.present
          ? data.description.value
          : this.description,
      grossAmount: data.grossAmount.present
          ? data.grossAmount.value
          : this.grossAmount,
      disbursementAmount: data.disbursementAmount.present
          ? data.disbursementAmount.value
          : this.disbursementAmount,
      attachmentFilename: data.attachmentFilename.present
          ? data.attachmentFilename.value
          : this.attachmentFilename,
      attachmentLocalPath: data.attachmentLocalPath.present
          ? data.attachmentLocalPath.value
          : this.attachmentLocalPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObligationRegistry(')
          ..write('id: $id, ')
          ..write('obrNo: $obrNo, ')
          ..write('date: $date, ')
          ..write('fundCode: $fundCode, ')
          ..write('accountCode: $accountCode, ')
          ..write('allotmentClassification: $allotmentClassification, ')
          ..write('payee: $payee, ')
          ..write('particular: $particular, ')
          ..write('description: $description, ')
          ..write('grossAmount: $grossAmount, ')
          ..write('disbursementAmount: $disbursementAmount, ')
          ..write('attachmentFilename: $attachmentFilename, ')
          ..write('attachmentLocalPath: $attachmentLocalPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    obrNo,
    date,
    fundCode,
    accountCode,
    allotmentClassification,
    payee,
    particular,
    description,
    grossAmount,
    disbursementAmount,
    attachmentFilename,
    attachmentLocalPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObligationRegistry &&
          other.id == this.id &&
          other.obrNo == this.obrNo &&
          other.date == this.date &&
          other.fundCode == this.fundCode &&
          other.accountCode == this.accountCode &&
          other.allotmentClassification == this.allotmentClassification &&
          other.payee == this.payee &&
          other.particular == this.particular &&
          other.description == this.description &&
          other.grossAmount == this.grossAmount &&
          other.disbursementAmount == this.disbursementAmount &&
          other.attachmentFilename == this.attachmentFilename &&
          other.attachmentLocalPath == this.attachmentLocalPath);
}

class ObligationRegistriesCompanion
    extends UpdateCompanion<ObligationRegistry> {
  final Value<int> id;
  final Value<String> obrNo;
  final Value<String> date;
  final Value<String> fundCode;
  final Value<String> accountCode;
  final Value<String> allotmentClassification;
  final Value<String> payee;
  final Value<String> particular;
  final Value<String?> description;
  final Value<double> grossAmount;
  final Value<double> disbursementAmount;
  final Value<String?> attachmentFilename;
  final Value<String?> attachmentLocalPath;
  const ObligationRegistriesCompanion({
    this.id = const Value.absent(),
    this.obrNo = const Value.absent(),
    this.date = const Value.absent(),
    this.fundCode = const Value.absent(),
    this.accountCode = const Value.absent(),
    this.allotmentClassification = const Value.absent(),
    this.payee = const Value.absent(),
    this.particular = const Value.absent(),
    this.description = const Value.absent(),
    this.grossAmount = const Value.absent(),
    this.disbursementAmount = const Value.absent(),
    this.attachmentFilename = const Value.absent(),
    this.attachmentLocalPath = const Value.absent(),
  });
  ObligationRegistriesCompanion.insert({
    this.id = const Value.absent(),
    required String obrNo,
    required String date,
    required String fundCode,
    required String accountCode,
    required String allotmentClassification,
    required String payee,
    required String particular,
    this.description = const Value.absent(),
    required double grossAmount,
    this.disbursementAmount = const Value.absent(),
    this.attachmentFilename = const Value.absent(),
    this.attachmentLocalPath = const Value.absent(),
  }) : obrNo = Value(obrNo),
       date = Value(date),
       fundCode = Value(fundCode),
       accountCode = Value(accountCode),
       allotmentClassification = Value(allotmentClassification),
       payee = Value(payee),
       particular = Value(particular),
       grossAmount = Value(grossAmount);
  static Insertable<ObligationRegistry> custom({
    Expression<int>? id,
    Expression<String>? obrNo,
    Expression<String>? date,
    Expression<String>? fundCode,
    Expression<String>? accountCode,
    Expression<String>? allotmentClassification,
    Expression<String>? payee,
    Expression<String>? particular,
    Expression<String>? description,
    Expression<double>? grossAmount,
    Expression<double>? disbursementAmount,
    Expression<String>? attachmentFilename,
    Expression<String>? attachmentLocalPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (obrNo != null) 'obr_no': obrNo,
      if (date != null) 'date': date,
      if (fundCode != null) 'fund_code': fundCode,
      if (accountCode != null) 'account_code': accountCode,
      if (allotmentClassification != null)
        'allotment_classification': allotmentClassification,
      if (payee != null) 'payee': payee,
      if (particular != null) 'particular': particular,
      if (description != null) 'description': description,
      if (grossAmount != null) 'gross_amount': grossAmount,
      if (disbursementAmount != null) 'disbursement_amount': disbursementAmount,
      if (attachmentFilename != null) 'attachment_filename': attachmentFilename,
      if (attachmentLocalPath != null)
        'attachment_local_path': attachmentLocalPath,
    });
  }

  ObligationRegistriesCompanion copyWith({
    Value<int>? id,
    Value<String>? obrNo,
    Value<String>? date,
    Value<String>? fundCode,
    Value<String>? accountCode,
    Value<String>? allotmentClassification,
    Value<String>? payee,
    Value<String>? particular,
    Value<String?>? description,
    Value<double>? grossAmount,
    Value<double>? disbursementAmount,
    Value<String?>? attachmentFilename,
    Value<String?>? attachmentLocalPath,
  }) {
    return ObligationRegistriesCompanion(
      id: id ?? this.id,
      obrNo: obrNo ?? this.obrNo,
      date: date ?? this.date,
      fundCode: fundCode ?? this.fundCode,
      accountCode: accountCode ?? this.accountCode,
      allotmentClassification:
          allotmentClassification ?? this.allotmentClassification,
      payee: payee ?? this.payee,
      particular: particular ?? this.particular,
      description: description ?? this.description,
      grossAmount: grossAmount ?? this.grossAmount,
      disbursementAmount: disbursementAmount ?? this.disbursementAmount,
      attachmentFilename: attachmentFilename ?? this.attachmentFilename,
      attachmentLocalPath: attachmentLocalPath ?? this.attachmentLocalPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (obrNo.present) {
      map['obr_no'] = Variable<String>(obrNo.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (fundCode.present) {
      map['fund_code'] = Variable<String>(fundCode.value);
    }
    if (accountCode.present) {
      map['account_code'] = Variable<String>(accountCode.value);
    }
    if (allotmentClassification.present) {
      map['allotment_classification'] = Variable<String>(
        allotmentClassification.value,
      );
    }
    if (payee.present) {
      map['payee'] = Variable<String>(payee.value);
    }
    if (particular.present) {
      map['particular'] = Variable<String>(particular.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (grossAmount.present) {
      map['gross_amount'] = Variable<double>(grossAmount.value);
    }
    if (disbursementAmount.present) {
      map['disbursement_amount'] = Variable<double>(disbursementAmount.value);
    }
    if (attachmentFilename.present) {
      map['attachment_filename'] = Variable<String>(attachmentFilename.value);
    }
    if (attachmentLocalPath.present) {
      map['attachment_local_path'] = Variable<String>(
        attachmentLocalPath.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObligationRegistriesCompanion(')
          ..write('id: $id, ')
          ..write('obrNo: $obrNo, ')
          ..write('date: $date, ')
          ..write('fundCode: $fundCode, ')
          ..write('accountCode: $accountCode, ')
          ..write('allotmentClassification: $allotmentClassification, ')
          ..write('payee: $payee, ')
          ..write('particular: $particular, ')
          ..write('description: $description, ')
          ..write('grossAmount: $grossAmount, ')
          ..write('disbursementAmount: $disbursementAmount, ')
          ..write('attachmentFilename: $attachmentFilename, ')
          ..write('attachmentLocalPath: $attachmentLocalPath')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FundSourcesTable fundSources = $FundSourcesTable(this);
  late final $UacsCodesTable uacsCodes = $UacsCodesTable(this);
  late final $BudgetAllocationsTable budgetAllocations =
      $BudgetAllocationsTable(this);
  late final $ObligationRegistriesTable obligationRegistries =
      $ObligationRegistriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    fundSources,
    uacsCodes,
    budgetAllocations,
    obligationRegistries,
  ];
}

typedef $$FundSourcesTableCreateCompanionBuilder =
    FundSourcesCompanion Function({
      required String fundCode,
      required String fundName,
      required String fundingSourceHeader,
      Value<int> rowid,
    });
typedef $$FundSourcesTableUpdateCompanionBuilder =
    FundSourcesCompanion Function({
      Value<String> fundCode,
      Value<String> fundName,
      Value<String> fundingSourceHeader,
      Value<int> rowid,
    });

final class $$FundSourcesTableReferences
    extends BaseReferences<_$AppDatabase, $FundSourcesTable, FundSource> {
  $$FundSourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BudgetAllocationsTable, List<BudgetAllocation>>
  _budgetAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.budgetAllocations,
        aliasName: 'fund_sources__fund_code__budget_allocations__fund_code',
      );

  $$BudgetAllocationsTableProcessedTableManager get budgetAllocationsRefs {
    final manager =
        $$BudgetAllocationsTableTableManager(
          $_db,
          $_db.budgetAllocations,
        ).filter(
          (f) =>
              f.fundCode.fundCode.sqlEquals($_itemColumn<String>('fund_code')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _budgetAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ObligationRegistriesTable,
    List<ObligationRegistry>
  >
  _obligationRegistriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.obligationRegistries,
        aliasName: 'fund_sources__fund_code__obligation_registries__fund_code',
      );

  $$ObligationRegistriesTableProcessedTableManager
  get obligationRegistriesRefs {
    final manager =
        $$ObligationRegistriesTableTableManager(
          $_db,
          $_db.obligationRegistries,
        ).filter(
          (f) =>
              f.fundCode.fundCode.sqlEquals($_itemColumn<String>('fund_code')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _obligationRegistriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FundSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $FundSourcesTable> {
  $$FundSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fundCode => $composableBuilder(
    column: $table.fundCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fundName => $composableBuilder(
    column: $table.fundName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fundingSourceHeader => $composableBuilder(
    column: $table.fundingSourceHeader,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> budgetAllocationsRefs(
    Expression<bool> Function($$BudgetAllocationsTableFilterComposer f) f,
  ) {
    final $$BudgetAllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fundCode,
      referencedTable: $db.budgetAllocations,
      getReferencedColumn: (t) => t.fundCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetAllocationsTableFilterComposer(
            $db: $db,
            $table: $db.budgetAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> obligationRegistriesRefs(
    Expression<bool> Function($$ObligationRegistriesTableFilterComposer f) f,
  ) {
    final $$ObligationRegistriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fundCode,
      referencedTable: $db.obligationRegistries,
      getReferencedColumn: (t) => t.fundCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationRegistriesTableFilterComposer(
            $db: $db,
            $table: $db.obligationRegistries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FundSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $FundSourcesTable> {
  $$FundSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fundCode => $composableBuilder(
    column: $table.fundCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fundName => $composableBuilder(
    column: $table.fundName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fundingSourceHeader => $composableBuilder(
    column: $table.fundingSourceHeader,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FundSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FundSourcesTable> {
  $$FundSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fundCode =>
      $composableBuilder(column: $table.fundCode, builder: (column) => column);

  GeneratedColumn<String> get fundName =>
      $composableBuilder(column: $table.fundName, builder: (column) => column);

  GeneratedColumn<String> get fundingSourceHeader => $composableBuilder(
    column: $table.fundingSourceHeader,
    builder: (column) => column,
  );

  Expression<T> budgetAllocationsRefs<T extends Object>(
    Expression<T> Function($$BudgetAllocationsTableAnnotationComposer a) f,
  ) {
    final $$BudgetAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.fundCode,
          referencedTable: $db.budgetAllocations,
          getReferencedColumn: (t) => t.fundCode,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BudgetAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.budgetAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> obligationRegistriesRefs<T extends Object>(
    Expression<T> Function($$ObligationRegistriesTableAnnotationComposer a) f,
  ) {
    final $$ObligationRegistriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.fundCode,
          referencedTable: $db.obligationRegistries,
          getReferencedColumn: (t) => t.fundCode,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ObligationRegistriesTableAnnotationComposer(
                $db: $db,
                $table: $db.obligationRegistries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$FundSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FundSourcesTable,
          FundSource,
          $$FundSourcesTableFilterComposer,
          $$FundSourcesTableOrderingComposer,
          $$FundSourcesTableAnnotationComposer,
          $$FundSourcesTableCreateCompanionBuilder,
          $$FundSourcesTableUpdateCompanionBuilder,
          (FundSource, $$FundSourcesTableReferences),
          FundSource,
          PrefetchHooks Function({
            bool budgetAllocationsRefs,
            bool obligationRegistriesRefs,
          })
        > {
  $$FundSourcesTableTableManager(_$AppDatabase db, $FundSourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FundSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FundSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FundSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> fundCode = const Value.absent(),
                Value<String> fundName = const Value.absent(),
                Value<String> fundingSourceHeader = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FundSourcesCompanion(
                fundCode: fundCode,
                fundName: fundName,
                fundingSourceHeader: fundingSourceHeader,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fundCode,
                required String fundName,
                required String fundingSourceHeader,
                Value<int> rowid = const Value.absent(),
              }) => FundSourcesCompanion.insert(
                fundCode: fundCode,
                fundName: fundName,
                fundingSourceHeader: fundingSourceHeader,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FundSourcesTable, FundSource>(table),
                  $$FundSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                budgetAllocationsRefs = false,
                obligationRegistriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (budgetAllocationsRefs) db.budgetAllocations,
                    if (obligationRegistriesRefs) db.obligationRegistries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (budgetAllocationsRefs)
                        await $_getPrefetchedDataByColumns<
                          FundSource,
                          $FundSourcesTable,
                          BudgetAllocation,
                          $BudgetAllocationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$FundSourcesTableReferences
                              ._budgetAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FundSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetAllocationsRefs,
                          currentColumn: 'fund_code',
                          referencedColumn: 'fund_code',
                          typedResults: items,
                        ),
                      if (obligationRegistriesRefs)
                        await $_getPrefetchedDataByColumns<
                          FundSource,
                          $FundSourcesTable,
                          ObligationRegistry,
                          $ObligationRegistriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$FundSourcesTableReferences
                              ._obligationRegistriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FundSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).obligationRegistriesRefs,
                          currentColumn: 'fund_code',
                          referencedColumn: 'fund_code',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FundSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FundSourcesTable,
      FundSource,
      $$FundSourcesTableFilterComposer,
      $$FundSourcesTableOrderingComposer,
      $$FundSourcesTableAnnotationComposer,
      $$FundSourcesTableCreateCompanionBuilder,
      $$FundSourcesTableUpdateCompanionBuilder,
      (FundSource, $$FundSourcesTableReferences),
      FundSource,
      PrefetchHooks Function({
        bool budgetAllocationsRefs,
        bool obligationRegistriesRefs,
      })
    >;
typedef $$UacsCodesTableCreateCompanionBuilder =
    UacsCodesCompanion Function({
      required String accountCode,
      required String objectTitle,
      required String allotmentClass,
      Value<int> rowid,
    });
typedef $$UacsCodesTableUpdateCompanionBuilder =
    UacsCodesCompanion Function({
      Value<String> accountCode,
      Value<String> objectTitle,
      Value<String> allotmentClass,
      Value<int> rowid,
    });

final class $$UacsCodesTableReferences
    extends BaseReferences<_$AppDatabase, $UacsCodesTable, UacsCode> {
  $$UacsCodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BudgetAllocationsTable, List<BudgetAllocation>>
  _budgetAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.budgetAllocations,
        aliasName: 'uacs_codes__account_code__budget_allocations__account_code',
      );

  $$BudgetAllocationsTableProcessedTableManager get budgetAllocationsRefs {
    final manager =
        $$BudgetAllocationsTableTableManager(
          $_db,
          $_db.budgetAllocations,
        ).filter(
          (f) => f.accountCode.accountCode.sqlEquals(
            $_itemColumn<String>('account_code')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _budgetAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ObligationRegistriesTable,
    List<ObligationRegistry>
  >
  _obligationRegistriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.obligationRegistries,
        aliasName:
            'uacs_codes__account_code__obligation_registries__account_code',
      );

  $$ObligationRegistriesTableProcessedTableManager
  get obligationRegistriesRefs {
    final manager =
        $$ObligationRegistriesTableTableManager(
          $_db,
          $_db.obligationRegistries,
        ).filter(
          (f) => f.accountCode.accountCode.sqlEquals(
            $_itemColumn<String>('account_code')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _obligationRegistriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UacsCodesTableFilterComposer
    extends Composer<_$AppDatabase, $UacsCodesTable> {
  $$UacsCodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountCode => $composableBuilder(
    column: $table.accountCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objectTitle => $composableBuilder(
    column: $table.objectTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allotmentClass => $composableBuilder(
    column: $table.allotmentClass,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> budgetAllocationsRefs(
    Expression<bool> Function($$BudgetAllocationsTableFilterComposer f) f,
  ) {
    final $$BudgetAllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountCode,
      referencedTable: $db.budgetAllocations,
      getReferencedColumn: (t) => t.accountCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetAllocationsTableFilterComposer(
            $db: $db,
            $table: $db.budgetAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> obligationRegistriesRefs(
    Expression<bool> Function($$ObligationRegistriesTableFilterComposer f) f,
  ) {
    final $$ObligationRegistriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountCode,
      referencedTable: $db.obligationRegistries,
      getReferencedColumn: (t) => t.accountCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationRegistriesTableFilterComposer(
            $db: $db,
            $table: $db.obligationRegistries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UacsCodesTableOrderingComposer
    extends Composer<_$AppDatabase, $UacsCodesTable> {
  $$UacsCodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountCode => $composableBuilder(
    column: $table.accountCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objectTitle => $composableBuilder(
    column: $table.objectTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allotmentClass => $composableBuilder(
    column: $table.allotmentClass,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UacsCodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UacsCodesTable> {
  $$UacsCodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountCode => $composableBuilder(
    column: $table.accountCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get objectTitle => $composableBuilder(
    column: $table.objectTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allotmentClass => $composableBuilder(
    column: $table.allotmentClass,
    builder: (column) => column,
  );

  Expression<T> budgetAllocationsRefs<T extends Object>(
    Expression<T> Function($$BudgetAllocationsTableAnnotationComposer a) f,
  ) {
    final $$BudgetAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.accountCode,
          referencedTable: $db.budgetAllocations,
          getReferencedColumn: (t) => t.accountCode,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BudgetAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.budgetAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> obligationRegistriesRefs<T extends Object>(
    Expression<T> Function($$ObligationRegistriesTableAnnotationComposer a) f,
  ) {
    final $$ObligationRegistriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.accountCode,
          referencedTable: $db.obligationRegistries,
          getReferencedColumn: (t) => t.accountCode,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ObligationRegistriesTableAnnotationComposer(
                $db: $db,
                $table: $db.obligationRegistries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$UacsCodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UacsCodesTable,
          UacsCode,
          $$UacsCodesTableFilterComposer,
          $$UacsCodesTableOrderingComposer,
          $$UacsCodesTableAnnotationComposer,
          $$UacsCodesTableCreateCompanionBuilder,
          $$UacsCodesTableUpdateCompanionBuilder,
          (UacsCode, $$UacsCodesTableReferences),
          UacsCode,
          PrefetchHooks Function({
            bool budgetAllocationsRefs,
            bool obligationRegistriesRefs,
          })
        > {
  $$UacsCodesTableTableManager(_$AppDatabase db, $UacsCodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UacsCodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UacsCodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UacsCodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountCode = const Value.absent(),
                Value<String> objectTitle = const Value.absent(),
                Value<String> allotmentClass = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UacsCodesCompanion(
                accountCode: accountCode,
                objectTitle: objectTitle,
                allotmentClass: allotmentClass,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountCode,
                required String objectTitle,
                required String allotmentClass,
                Value<int> rowid = const Value.absent(),
              }) => UacsCodesCompanion.insert(
                accountCode: accountCode,
                objectTitle: objectTitle,
                allotmentClass: allotmentClass,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UacsCodesTable, UacsCode>(table),
                  $$UacsCodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                budgetAllocationsRefs = false,
                obligationRegistriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (budgetAllocationsRefs) db.budgetAllocations,
                    if (obligationRegistriesRefs) db.obligationRegistries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (budgetAllocationsRefs)
                        await $_getPrefetchedDataByColumns<
                          UacsCode,
                          $UacsCodesTable,
                          BudgetAllocation,
                          $BudgetAllocationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$UacsCodesTableReferences
                              ._budgetAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UacsCodesTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetAllocationsRefs,
                          currentColumn: 'account_code',
                          referencedColumn: 'account_code',
                          typedResults: items,
                        ),
                      if (obligationRegistriesRefs)
                        await $_getPrefetchedDataByColumns<
                          UacsCode,
                          $UacsCodesTable,
                          ObligationRegistry,
                          $ObligationRegistriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$UacsCodesTableReferences
                              ._obligationRegistriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UacsCodesTableReferences(
                                db,
                                table,
                                p0,
                              ).obligationRegistriesRefs,
                          currentColumn: 'account_code',
                          referencedColumn: 'account_code',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UacsCodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UacsCodesTable,
      UacsCode,
      $$UacsCodesTableFilterComposer,
      $$UacsCodesTableOrderingComposer,
      $$UacsCodesTableAnnotationComposer,
      $$UacsCodesTableCreateCompanionBuilder,
      $$UacsCodesTableUpdateCompanionBuilder,
      (UacsCode, $$UacsCodesTableReferences),
      UacsCode,
      PrefetchHooks Function({
        bool budgetAllocationsRefs,
        bool obligationRegistriesRefs,
      })
    >;
typedef $$BudgetAllocationsTableCreateCompanionBuilder =
    BudgetAllocationsCompanion Function({
      Value<int> id,
      required String fiscalYear,
      required String fundCode,
      required String allotmentClass,
      Value<String?> accountCode,
      Value<double> authorizedAppropriations,
      Value<double> adjustmentsAppropriations,
      Value<double> allotmentReceived,
      Value<double> adjustmentsAllotment,
      required String dateOfAllocation,
      Value<int> isHidden,
    });
typedef $$BudgetAllocationsTableUpdateCompanionBuilder =
    BudgetAllocationsCompanion Function({
      Value<int> id,
      Value<String> fiscalYear,
      Value<String> fundCode,
      Value<String> allotmentClass,
      Value<String?> accountCode,
      Value<double> authorizedAppropriations,
      Value<double> adjustmentsAppropriations,
      Value<double> allotmentReceived,
      Value<double> adjustmentsAllotment,
      Value<String> dateOfAllocation,
      Value<int> isHidden,
    });

final class $$BudgetAllocationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BudgetAllocationsTable,
          BudgetAllocation
        > {
  $$BudgetAllocationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FundSourcesTable _fundCodeTable(_$AppDatabase db) => db.fundSources
      .createAlias('budget_allocations__fund_code__fund_sources__fund_code');

  $$FundSourcesTableProcessedTableManager get fundCode {
    final $_column = $_itemColumn<String>('fund_code')!;

    final manager = $$FundSourcesTableTableManager(
      $_db,
      $_db.fundSources,
    ).filter((f) => f.fundCode.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fundCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UacsCodesTable _accountCodeTable(_$AppDatabase db) =>
      db.uacsCodes.createAlias(
        'budget_allocations__account_code__uacs_codes__account_code',
      );

  $$UacsCodesTableProcessedTableManager? get accountCode {
    final $_column = $_itemColumn<String>('account_code');
    if ($_column == null) return null;
    final manager = $$UacsCodesTableTableManager(
      $_db,
      $_db.uacsCodes,
    ).filter((f) => f.accountCode.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BudgetAllocationsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetAllocationsTable> {
  $$BudgetAllocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fiscalYear => $composableBuilder(
    column: $table.fiscalYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allotmentClass => $composableBuilder(
    column: $table.allotmentClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get authorizedAppropriations => $composableBuilder(
    column: $table.authorizedAppropriations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get adjustmentsAppropriations => $composableBuilder(
    column: $table.adjustmentsAppropriations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get allotmentReceived => $composableBuilder(
    column: $table.allotmentReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get adjustmentsAllotment => $composableBuilder(
    column: $table.adjustmentsAllotment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateOfAllocation => $composableBuilder(
    column: $table.dateOfAllocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  $$FundSourcesTableFilterComposer get fundCode {
    final $$FundSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fundCode,
      referencedTable: $db.fundSources,
      getReferencedColumn: (t) => t.fundCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FundSourcesTableFilterComposer(
            $db: $db,
            $table: $db.fundSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UacsCodesTableFilterComposer get accountCode {
    final $$UacsCodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountCode,
      referencedTable: $db.uacsCodes,
      getReferencedColumn: (t) => t.accountCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UacsCodesTableFilterComposer(
            $db: $db,
            $table: $db.uacsCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetAllocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetAllocationsTable> {
  $$BudgetAllocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fiscalYear => $composableBuilder(
    column: $table.fiscalYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allotmentClass => $composableBuilder(
    column: $table.allotmentClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get authorizedAppropriations => $composableBuilder(
    column: $table.authorizedAppropriations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get adjustmentsAppropriations => $composableBuilder(
    column: $table.adjustmentsAppropriations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get allotmentReceived => $composableBuilder(
    column: $table.allotmentReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get adjustmentsAllotment => $composableBuilder(
    column: $table.adjustmentsAllotment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateOfAllocation => $composableBuilder(
    column: $table.dateOfAllocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  $$FundSourcesTableOrderingComposer get fundCode {
    final $$FundSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fundCode,
      referencedTable: $db.fundSources,
      getReferencedColumn: (t) => t.fundCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FundSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.fundSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UacsCodesTableOrderingComposer get accountCode {
    final $$UacsCodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountCode,
      referencedTable: $db.uacsCodes,
      getReferencedColumn: (t) => t.accountCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UacsCodesTableOrderingComposer(
            $db: $db,
            $table: $db.uacsCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetAllocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetAllocationsTable> {
  $$BudgetAllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fiscalYear => $composableBuilder(
    column: $table.fiscalYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allotmentClass => $composableBuilder(
    column: $table.allotmentClass,
    builder: (column) => column,
  );

  GeneratedColumn<double> get authorizedAppropriations => $composableBuilder(
    column: $table.authorizedAppropriations,
    builder: (column) => column,
  );

  GeneratedColumn<double> get adjustmentsAppropriations => $composableBuilder(
    column: $table.adjustmentsAppropriations,
    builder: (column) => column,
  );

  GeneratedColumn<double> get allotmentReceived => $composableBuilder(
    column: $table.allotmentReceived,
    builder: (column) => column,
  );

  GeneratedColumn<double> get adjustmentsAllotment => $composableBuilder(
    column: $table.adjustmentsAllotment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateOfAllocation => $composableBuilder(
    column: $table.dateOfAllocation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  $$FundSourcesTableAnnotationComposer get fundCode {
    final $$FundSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fundCode,
      referencedTable: $db.fundSources,
      getReferencedColumn: (t) => t.fundCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FundSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.fundSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UacsCodesTableAnnotationComposer get accountCode {
    final $$UacsCodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountCode,
      referencedTable: $db.uacsCodes,
      getReferencedColumn: (t) => t.accountCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UacsCodesTableAnnotationComposer(
            $db: $db,
            $table: $db.uacsCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetAllocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetAllocationsTable,
          BudgetAllocation,
          $$BudgetAllocationsTableFilterComposer,
          $$BudgetAllocationsTableOrderingComposer,
          $$BudgetAllocationsTableAnnotationComposer,
          $$BudgetAllocationsTableCreateCompanionBuilder,
          $$BudgetAllocationsTableUpdateCompanionBuilder,
          (BudgetAllocation, $$BudgetAllocationsTableReferences),
          BudgetAllocation,
          PrefetchHooks Function({bool fundCode, bool accountCode})
        > {
  $$BudgetAllocationsTableTableManager(
    _$AppDatabase db,
    $BudgetAllocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetAllocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetAllocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetAllocationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> fiscalYear = const Value.absent(),
                Value<String> fundCode = const Value.absent(),
                Value<String> allotmentClass = const Value.absent(),
                Value<String?> accountCode = const Value.absent(),
                Value<double> authorizedAppropriations = const Value.absent(),
                Value<double> adjustmentsAppropriations = const Value.absent(),
                Value<double> allotmentReceived = const Value.absent(),
                Value<double> adjustmentsAllotment = const Value.absent(),
                Value<String> dateOfAllocation = const Value.absent(),
                Value<int> isHidden = const Value.absent(),
              }) => BudgetAllocationsCompanion(
                id: id,
                fiscalYear: fiscalYear,
                fundCode: fundCode,
                allotmentClass: allotmentClass,
                accountCode: accountCode,
                authorizedAppropriations: authorizedAppropriations,
                adjustmentsAppropriations: adjustmentsAppropriations,
                allotmentReceived: allotmentReceived,
                adjustmentsAllotment: adjustmentsAllotment,
                dateOfAllocation: dateOfAllocation,
                isHidden: isHidden,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String fiscalYear,
                required String fundCode,
                required String allotmentClass,
                Value<String?> accountCode = const Value.absent(),
                Value<double> authorizedAppropriations = const Value.absent(),
                Value<double> adjustmentsAppropriations = const Value.absent(),
                Value<double> allotmentReceived = const Value.absent(),
                Value<double> adjustmentsAllotment = const Value.absent(),
                required String dateOfAllocation,
                Value<int> isHidden = const Value.absent(),
              }) => BudgetAllocationsCompanion.insert(
                id: id,
                fiscalYear: fiscalYear,
                fundCode: fundCode,
                allotmentClass: allotmentClass,
                accountCode: accountCode,
                authorizedAppropriations: authorizedAppropriations,
                adjustmentsAppropriations: adjustmentsAppropriations,
                allotmentReceived: allotmentReceived,
                adjustmentsAllotment: adjustmentsAllotment,
                dateOfAllocation: dateOfAllocation,
                isHidden: isHidden,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetAllocationsTable, BudgetAllocation>(table),
                  $$BudgetAllocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fundCode = false, accountCode = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fundCode) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fundCode,
                                referencedTable:
                                    $$BudgetAllocationsTableReferences
                                        ._fundCodeTable(db),
                                referencedColumn:
                                    $$BudgetAllocationsTableReferences
                                        ._fundCodeTable(db)
                                        .fundCode,
                              )
                              as T;
                    }
                    if (accountCode) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountCode,
                                referencedTable:
                                    $$BudgetAllocationsTableReferences
                                        ._accountCodeTable(db),
                                referencedColumn:
                                    $$BudgetAllocationsTableReferences
                                        ._accountCodeTable(db)
                                        .accountCode,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BudgetAllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetAllocationsTable,
      BudgetAllocation,
      $$BudgetAllocationsTableFilterComposer,
      $$BudgetAllocationsTableOrderingComposer,
      $$BudgetAllocationsTableAnnotationComposer,
      $$BudgetAllocationsTableCreateCompanionBuilder,
      $$BudgetAllocationsTableUpdateCompanionBuilder,
      (BudgetAllocation, $$BudgetAllocationsTableReferences),
      BudgetAllocation,
      PrefetchHooks Function({bool fundCode, bool accountCode})
    >;
typedef $$ObligationRegistriesTableCreateCompanionBuilder =
    ObligationRegistriesCompanion Function({
      Value<int> id,
      required String obrNo,
      required String date,
      required String fundCode,
      required String accountCode,
      required String allotmentClassification,
      required String payee,
      required String particular,
      Value<String?> description,
      required double grossAmount,
      Value<double> disbursementAmount,
      Value<String?> attachmentFilename,
      Value<String?> attachmentLocalPath,
    });
typedef $$ObligationRegistriesTableUpdateCompanionBuilder =
    ObligationRegistriesCompanion Function({
      Value<int> id,
      Value<String> obrNo,
      Value<String> date,
      Value<String> fundCode,
      Value<String> accountCode,
      Value<String> allotmentClassification,
      Value<String> payee,
      Value<String> particular,
      Value<String?> description,
      Value<double> grossAmount,
      Value<double> disbursementAmount,
      Value<String?> attachmentFilename,
      Value<String?> attachmentLocalPath,
    });

final class $$ObligationRegistriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ObligationRegistriesTable,
          ObligationRegistry
        > {
  $$ObligationRegistriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FundSourcesTable _fundCodeTable(_$AppDatabase db) => db.fundSources
      .createAlias('obligation_registries__fund_code__fund_sources__fund_code');

  $$FundSourcesTableProcessedTableManager get fundCode {
    final $_column = $_itemColumn<String>('fund_code')!;

    final manager = $$FundSourcesTableTableManager(
      $_db,
      $_db.fundSources,
    ).filter((f) => f.fundCode.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fundCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UacsCodesTable _accountCodeTable(_$AppDatabase db) =>
      db.uacsCodes.createAlias(
        'obligation_registries__account_code__uacs_codes__account_code',
      );

  $$UacsCodesTableProcessedTableManager get accountCode {
    final $_column = $_itemColumn<String>('account_code')!;

    final manager = $$UacsCodesTableTableManager(
      $_db,
      $_db.uacsCodes,
    ).filter((f) => f.accountCode.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ObligationRegistriesTableFilterComposer
    extends Composer<_$AppDatabase, $ObligationRegistriesTable> {
  $$ObligationRegistriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get obrNo => $composableBuilder(
    column: $table.obrNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allotmentClassification => $composableBuilder(
    column: $table.allotmentClassification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payee => $composableBuilder(
    column: $table.payee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get particular => $composableBuilder(
    column: $table.particular,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grossAmount => $composableBuilder(
    column: $table.grossAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get disbursementAmount => $composableBuilder(
    column: $table.disbursementAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentFilename => $composableBuilder(
    column: $table.attachmentFilename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentLocalPath => $composableBuilder(
    column: $table.attachmentLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  $$FundSourcesTableFilterComposer get fundCode {
    final $$FundSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fundCode,
      referencedTable: $db.fundSources,
      getReferencedColumn: (t) => t.fundCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FundSourcesTableFilterComposer(
            $db: $db,
            $table: $db.fundSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UacsCodesTableFilterComposer get accountCode {
    final $$UacsCodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountCode,
      referencedTable: $db.uacsCodes,
      getReferencedColumn: (t) => t.accountCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UacsCodesTableFilterComposer(
            $db: $db,
            $table: $db.uacsCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObligationRegistriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ObligationRegistriesTable> {
  $$ObligationRegistriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get obrNo => $composableBuilder(
    column: $table.obrNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allotmentClassification => $composableBuilder(
    column: $table.allotmentClassification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payee => $composableBuilder(
    column: $table.payee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get particular => $composableBuilder(
    column: $table.particular,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grossAmount => $composableBuilder(
    column: $table.grossAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get disbursementAmount => $composableBuilder(
    column: $table.disbursementAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentFilename => $composableBuilder(
    column: $table.attachmentFilename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentLocalPath => $composableBuilder(
    column: $table.attachmentLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  $$FundSourcesTableOrderingComposer get fundCode {
    final $$FundSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fundCode,
      referencedTable: $db.fundSources,
      getReferencedColumn: (t) => t.fundCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FundSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.fundSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UacsCodesTableOrderingComposer get accountCode {
    final $$UacsCodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountCode,
      referencedTable: $db.uacsCodes,
      getReferencedColumn: (t) => t.accountCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UacsCodesTableOrderingComposer(
            $db: $db,
            $table: $db.uacsCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObligationRegistriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObligationRegistriesTable> {
  $$ObligationRegistriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get obrNo =>
      $composableBuilder(column: $table.obrNo, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get allotmentClassification => $composableBuilder(
    column: $table.allotmentClassification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payee =>
      $composableBuilder(column: $table.payee, builder: (column) => column);

  GeneratedColumn<String> get particular => $composableBuilder(
    column: $table.particular,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get grossAmount => $composableBuilder(
    column: $table.grossAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get disbursementAmount => $composableBuilder(
    column: $table.disbursementAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attachmentFilename => $composableBuilder(
    column: $table.attachmentFilename,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attachmentLocalPath => $composableBuilder(
    column: $table.attachmentLocalPath,
    builder: (column) => column,
  );

  $$FundSourcesTableAnnotationComposer get fundCode {
    final $$FundSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fundCode,
      referencedTable: $db.fundSources,
      getReferencedColumn: (t) => t.fundCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FundSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.fundSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UacsCodesTableAnnotationComposer get accountCode {
    final $$UacsCodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountCode,
      referencedTable: $db.uacsCodes,
      getReferencedColumn: (t) => t.accountCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UacsCodesTableAnnotationComposer(
            $db: $db,
            $table: $db.uacsCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObligationRegistriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObligationRegistriesTable,
          ObligationRegistry,
          $$ObligationRegistriesTableFilterComposer,
          $$ObligationRegistriesTableOrderingComposer,
          $$ObligationRegistriesTableAnnotationComposer,
          $$ObligationRegistriesTableCreateCompanionBuilder,
          $$ObligationRegistriesTableUpdateCompanionBuilder,
          (ObligationRegistry, $$ObligationRegistriesTableReferences),
          ObligationRegistry,
          PrefetchHooks Function({bool fundCode, bool accountCode})
        > {
  $$ObligationRegistriesTableTableManager(
    _$AppDatabase db,
    $ObligationRegistriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObligationRegistriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObligationRegistriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ObligationRegistriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> obrNo = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> fundCode = const Value.absent(),
                Value<String> accountCode = const Value.absent(),
                Value<String> allotmentClassification = const Value.absent(),
                Value<String> payee = const Value.absent(),
                Value<String> particular = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> grossAmount = const Value.absent(),
                Value<double> disbursementAmount = const Value.absent(),
                Value<String?> attachmentFilename = const Value.absent(),
                Value<String?> attachmentLocalPath = const Value.absent(),
              }) => ObligationRegistriesCompanion(
                id: id,
                obrNo: obrNo,
                date: date,
                fundCode: fundCode,
                accountCode: accountCode,
                allotmentClassification: allotmentClassification,
                payee: payee,
                particular: particular,
                description: description,
                grossAmount: grossAmount,
                disbursementAmount: disbursementAmount,
                attachmentFilename: attachmentFilename,
                attachmentLocalPath: attachmentLocalPath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String obrNo,
                required String date,
                required String fundCode,
                required String accountCode,
                required String allotmentClassification,
                required String payee,
                required String particular,
                Value<String?> description = const Value.absent(),
                required double grossAmount,
                Value<double> disbursementAmount = const Value.absent(),
                Value<String?> attachmentFilename = const Value.absent(),
                Value<String?> attachmentLocalPath = const Value.absent(),
              }) => ObligationRegistriesCompanion.insert(
                id: id,
                obrNo: obrNo,
                date: date,
                fundCode: fundCode,
                accountCode: accountCode,
                allotmentClassification: allotmentClassification,
                payee: payee,
                particular: particular,
                description: description,
                grossAmount: grossAmount,
                disbursementAmount: disbursementAmount,
                attachmentFilename: attachmentFilename,
                attachmentLocalPath: attachmentLocalPath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ObligationRegistriesTable, ObligationRegistry>(
                    table,
                  ),
                  $$ObligationRegistriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fundCode = false, accountCode = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fundCode) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fundCode,
                                referencedTable:
                                    $$ObligationRegistriesTableReferences
                                        ._fundCodeTable(db),
                                referencedColumn:
                                    $$ObligationRegistriesTableReferences
                                        ._fundCodeTable(db)
                                        .fundCode,
                              )
                              as T;
                    }
                    if (accountCode) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountCode,
                                referencedTable:
                                    $$ObligationRegistriesTableReferences
                                        ._accountCodeTable(db),
                                referencedColumn:
                                    $$ObligationRegistriesTableReferences
                                        ._accountCodeTable(db)
                                        .accountCode,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ObligationRegistriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObligationRegistriesTable,
      ObligationRegistry,
      $$ObligationRegistriesTableFilterComposer,
      $$ObligationRegistriesTableOrderingComposer,
      $$ObligationRegistriesTableAnnotationComposer,
      $$ObligationRegistriesTableCreateCompanionBuilder,
      $$ObligationRegistriesTableUpdateCompanionBuilder,
      (ObligationRegistry, $$ObligationRegistriesTableReferences),
      ObligationRegistry,
      PrefetchHooks Function({bool fundCode, bool accountCode})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FundSourcesTableTableManager get fundSources =>
      $$FundSourcesTableTableManager(_db, _db.fundSources);
  $$UacsCodesTableTableManager get uacsCodes =>
      $$UacsCodesTableTableManager(_db, _db.uacsCodes);
  $$BudgetAllocationsTableTableManager get budgetAllocations =>
      $$BudgetAllocationsTableTableManager(_db, _db.budgetAllocations);
  $$ObligationRegistriesTableTableManager get obligationRegistries =>
      $$ObligationRegistriesTableTableManager(_db, _db.obligationRegistries);
}
