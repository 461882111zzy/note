// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetWorkSpaceDataCollection on Isar {
  IsarCollection<WorkSpaceData> get workSpaceDatas => this.collection();
}

const WorkSpaceDataSchema = CollectionSchema(
  name: r'WorkSpaceData',
  id: -6701033420212406919,
  properties: {
    r'createTime': PropertySchema(
      id: 0,
      name: r'createTime',
      type: IsarType.long,
    ),
    r'dirs': PropertySchema(
      id: 1,
      name: r'dirs',
      type: IsarType.objectList,
      target: r'FolderData',
    ),
    r'status': PropertySchema(
      id: 2,
      name: r'status',
      type: IsarType.byte,
      enumMap: _WorkSpaceDatastatusEnumValueMap,
    ),
    r'title': PropertySchema(
      id: 3,
      name: r'title',
      type: IsarType.string,
    ),
    r'updateTime': PropertySchema(
      id: 4,
      name: r'updateTime',
      type: IsarType.long,
    )
  },
  estimateSize: _workSpaceDataEstimateSize,
  serialize: _workSpaceDataSerialize,
  deserialize: _workSpaceDataDeserialize,
  deserializeProp: _workSpaceDataDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'FolderData': FolderDataSchema},
  getId: _workSpaceDataGetId,
  getLinks: _workSpaceDataGetLinks,
  attach: _workSpaceDataAttach,
  version: '3.0.5',
);

int _workSpaceDataEstimateSize(
  WorkSpaceData object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.dirs;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[FolderData]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              FolderDataSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _workSpaceDataSerialize(
  WorkSpaceData object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.createTime);
  writer.writeObjectList<FolderData>(
    offsets[1],
    allOffsets,
    FolderDataSchema.serialize,
    object.dirs,
  );
  writer.writeByte(offsets[2], object.status.index);
  writer.writeString(offsets[3], object.title);
  writer.writeLong(offsets[4], object.updateTime);
}

WorkSpaceData _workSpaceDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkSpaceData();
  object.createTime = reader.readLongOrNull(offsets[0]);
  object.dirs = reader.readObjectList<FolderData>(
    offsets[1],
    FolderDataSchema.deserialize,
    allOffsets,
    FolderData(),
  );
  object.id = id;
  object.status =
      _WorkSpaceDatastatusValueEnumMap[reader.readByteOrNull(offsets[2])] ??
          Status.unknown;
  object.title = reader.readString(offsets[3]);
  object.updateTime = reader.readLongOrNull(offsets[4]);
  return object;
}

P _workSpaceDataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readObjectList<FolderData>(
        offset,
        FolderDataSchema.deserialize,
        allOffsets,
        FolderData(),
      )) as P;
    case 2:
      return (_WorkSpaceDatastatusValueEnumMap[reader.readByteOrNull(offset)] ??
          Status.unknown) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _WorkSpaceDatastatusEnumValueMap = {
  'unknown': 0,
  'deleted': 1,
};
const _WorkSpaceDatastatusValueEnumMap = {
  0: Status.unknown,
  1: Status.deleted,
};

Id _workSpaceDataGetId(WorkSpaceData object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _workSpaceDataGetLinks(WorkSpaceData object) {
  return [];
}

void _workSpaceDataAttach(
    IsarCollection<dynamic> col, Id id, WorkSpaceData object) {
  object.id = id;
}

extension WorkSpaceDataQueryWhereSort
    on QueryBuilder<WorkSpaceData, WorkSpaceData, QWhere> {
  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WorkSpaceDataQueryWhere
    on QueryBuilder<WorkSpaceData, WorkSpaceData, QWhereClause> {
  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkSpaceDataQueryFilter
    on QueryBuilder<WorkSpaceData, WorkSpaceData, QFilterCondition> {
  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      createTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createTime',
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      createTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createTime',
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      createTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      createTimeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      createTimeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      createTimeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      dirsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dirs',
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      dirsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dirs',
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      dirsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dirs',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      dirsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dirs',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      dirsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dirs',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      dirsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dirs',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      dirsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dirs',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      dirsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dirs',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      statusEqualTo(Status value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      statusGreaterThan(
    Status value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      statusLessThan(
    Status value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      statusBetween(
    Status lower,
    Status upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      updateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updateTime',
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      updateTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updateTime',
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      updateTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      updateTimeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      updateTimeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition>
      updateTimeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkSpaceDataQueryObject
    on QueryBuilder<WorkSpaceData, WorkSpaceData, QFilterCondition> {
  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterFilterCondition> dirsElement(
      FilterQuery<FolderData> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'dirs');
    });
  }
}

extension WorkSpaceDataQueryLinks
    on QueryBuilder<WorkSpaceData, WorkSpaceData, QFilterCondition> {}

extension WorkSpaceDataQuerySortBy
    on QueryBuilder<WorkSpaceData, WorkSpaceData, QSortBy> {
  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy> sortByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.asc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy>
      sortByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.desc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy> sortByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.asc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy>
      sortByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.desc);
    });
  }
}

extension WorkSpaceDataQuerySortThenBy
    on QueryBuilder<WorkSpaceData, WorkSpaceData, QSortThenBy> {
  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy> thenByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.asc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy>
      thenByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.desc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy> thenByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.asc);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QAfterSortBy>
      thenByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.desc);
    });
  }
}

extension WorkSpaceDataQueryWhereDistinct
    on QueryBuilder<WorkSpaceData, WorkSpaceData, QDistinct> {
  QueryBuilder<WorkSpaceData, WorkSpaceData, QDistinct> distinctByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createTime');
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkSpaceData, WorkSpaceData, QDistinct> distinctByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updateTime');
    });
  }
}

extension WorkSpaceDataQueryProperty
    on QueryBuilder<WorkSpaceData, WorkSpaceData, QQueryProperty> {
  QueryBuilder<WorkSpaceData, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WorkSpaceData, int?, QQueryOperations> createTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createTime');
    });
  }

  QueryBuilder<WorkSpaceData, List<FolderData>?, QQueryOperations>
      dirsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dirs');
    });
  }

  QueryBuilder<WorkSpaceData, Status, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<WorkSpaceData, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<WorkSpaceData, int?, QQueryOperations> updateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updateTime');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

const FolderDataSchema = Schema(
  name: r'FolderData',
  id: -8858938334962958355,
  properties: {
    r'assets': PropertySchema(
      id: 0,
      name: r'assets',
      type: IsarType.longList,
    ),
    r'createTime': PropertySchema(
      id: 1,
      name: r'createTime',
      type: IsarType.long,
    ),
    r'parentId': PropertySchema(
      id: 2,
      name: r'parentId',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 3,
      name: r'status',
      type: IsarType.byte,
      enumMap: _FolderDatastatusEnumValueMap,
    ),
    r'tasks': PropertySchema(
      id: 4,
      name: r'tasks',
      type: IsarType.longList,
    ),
    r'title': PropertySchema(
      id: 5,
      name: r'title',
      type: IsarType.string,
    ),
    r'updateTime': PropertySchema(
      id: 6,
      name: r'updateTime',
      type: IsarType.long,
    )
  },
  estimateSize: _folderDataEstimateSize,
  serialize: _folderDataSerialize,
  deserialize: _folderDataDeserialize,
  deserializeProp: _folderDataDeserializeProp,
);

int _folderDataEstimateSize(
  FolderData object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.assets;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final value = object.tasks;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _folderDataSerialize(
  FolderData object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLongList(offsets[0], object.assets);
  writer.writeLong(offsets[1], object.createTime);
  writer.writeLong(offsets[2], object.parentId);
  writer.writeByte(offsets[3], object.status.index);
  writer.writeLongList(offsets[4], object.tasks);
  writer.writeString(offsets[5], object.title);
  writer.writeLong(offsets[6], object.updateTime);
}

FolderData _folderDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FolderData();
  object.assets = reader.readLongList(offsets[0]);
  object.createTime = reader.readLongOrNull(offsets[1]);
  object.parentId = reader.readLong(offsets[2]);
  object.status =
      _FolderDatastatusValueEnumMap[reader.readByteOrNull(offsets[3])] ??
          Status.unknown;
  object.tasks = reader.readLongList(offsets[4]);
  object.title = reader.readString(offsets[5]);
  object.updateTime = reader.readLongOrNull(offsets[6]);
  return object;
}

P _folderDataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongList(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (_FolderDatastatusValueEnumMap[reader.readByteOrNull(offset)] ??
          Status.unknown) as P;
    case 4:
      return (reader.readLongList(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _FolderDatastatusEnumValueMap = {
  'unknown': 0,
  'deleted': 1,
};
const _FolderDatastatusValueEnumMap = {
  0: Status.unknown,
  1: Status.deleted,
};

extension FolderDataQueryFilter
    on QueryBuilder<FolderData, FolderData, QFilterCondition> {
  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> assetsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assets',
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      assetsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assets',
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      assetsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assets',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      assetsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assets',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      assetsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assets',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      assetsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assets',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      assetsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assets',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> assetsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assets',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      assetsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assets',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      assetsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assets',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      assetsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assets',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      assetsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assets',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      createTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createTime',
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      createTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createTime',
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> createTimeEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      createTimeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      createTimeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> createTimeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> parentIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentId',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      parentIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentId',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> parentIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentId',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> parentIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> statusEqualTo(
      Status value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> statusGreaterThan(
    Status value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> statusLessThan(
    Status value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> statusBetween(
    Status lower,
    Status upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> tasksIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tasks',
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> tasksIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tasks',
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      tasksElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tasks',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      tasksElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tasks',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      tasksElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tasks',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      tasksElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tasks',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      tasksLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tasks',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> tasksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tasks',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      tasksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tasks',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      tasksLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tasks',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      tasksLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tasks',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      tasksLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tasks',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      updateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updateTime',
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      updateTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updateTime',
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> updateTimeEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      updateTimeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition>
      updateTimeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FolderData, FolderData, QAfterFilterCondition> updateTimeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FolderDataQueryObject
    on QueryBuilder<FolderData, FolderData, QFilterCondition> {}
