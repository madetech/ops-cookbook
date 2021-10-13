/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
import React from 'react';
import clsx from 'clsx';
import styles from './HomepageFeatures.module.css';

type FeatureItem = {
  title: string;
  image: string;
  description: JSX.Element;
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Use only what you need',
    image: '/img/undraw_docusaurus_mountain.svg',
    description: (
      <>
        Take the recipes you need, igmnore the ones you don't.
      </>
    ),
  },
  {
    title: 'Save time',
    image: '/img/undraw_docusaurus_tree.svg',
    description: (
      <>
        Don't re-invent the wheel.
      </>
    ),
  },
  {
    title: 'Greater consistency',
    image: '/img/undraw_docusaurus_react.svg',
    description: (
      <>
        A starting point to bring together learnings and best practise.
      </>
    ),
  },
];

function Feature({title, image, description}: FeatureItem) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <img className={styles.featureSvg} alt={title} src={image} />
      </div>
      <div className="text--center padding-horiz--md">
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): JSX.Element {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
